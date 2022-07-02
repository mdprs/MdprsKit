//
//  SlidedeckService.swift
//  mdprsKit
//
//  Created by Thomas Bonk on 01.07.22.
//  Copyright 2022 Thomas Bonk <thomas@meandmymac.de>
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Files
import Foundation
import Swifter

public class SlidedeckService {

  // MARK: - Public Properties

  public let port = SlidedeckService.freePort()
  public var slidedeck: String = "" {
    didSet {
      webSocketSessions.forEach { session in
        session.writeText("UPDATE")
      }
    }
  }


  // MARK: - Private Properties

  private let server = HttpServer()
  private var webSocketSessions = [WebSocketSession]()
  private let parser = Parser()


  // MARK: - Initialization

  public init(custom mapping: [(path: String, mappedTo: String)] = []) {
    configure(server, custom: mapping)
  }


  // MARK: - Public Methods

  public func start() throws {
    try server.start(self.port, forceIPv4: true, priority: .background)
  }


  // MARK: - Private Methods

  private func configure(_ server: HttpServer, custom mapping: [(path: String, mappedTo: String)]) {
    server.listenAddressIPv4 = "0.0.0.0"

    server["/"] = renderSlideDeck(request:)
    expose(custom: mapping, to: server)
    exposeFiles(to: server)
    server["/notification"] = websocket(connected: { session in
      self.webSocketSessions.append(session)
    }, disconnected: { session in
      self.webSocketSessions.removeAll { wss in wss == session }
    })
  }

  private func renderSlideDeck(request: HttpRequest) -> HttpResponse {
    do {
      let presentation = parser.parse(markdown: slidedeck)
      let html = try presentation.render()

      return .ok(.htmlBody(html))
    } catch {
      return .internalServerError
    }
  }

  private func expose(custom mapping: [(path: String, mappedTo: String)], to server: HttpServer) {
    mapping.forEach { (path: String, mappedTo: String) in
      exposeFiles(from: path, pathPrefix: mappedTo, to: server)
    }
  }

  private func exposeFiles(to server: HttpServer) {
    let distPath = Bundle.module.path(forResource: "reveal.js/dist", ofType: "")!
    let pluginPath = Bundle.module.path(forResource: "reveal.js/plugin", ofType: "")!

    exposeFiles(from: distPath, pathPrefix: "/dist", to: server)
    exposeFiles(from: pluginPath, pathPrefix: "/plugin", to: server)
  }

  private func exposeFiles(from basePath: String, pathPrefix: String, to server: HttpServer) {
    if let folder = try? Folder(path: basePath) {
      folder.files.forEach { file in
        let exposedPath = "\(pathPrefix)/\(file.name)"
        server[exposedPath] = shareFile(file.url.path)
      }

      folder.subfolders.forEach { folder in
        exposeFiles(from: "\(basePath)/\(folder.name)", pathPrefix: "\(pathPrefix)/\(folder.name)", to: server)
      }
    }
  }


  // MARK: - Private Static Methods

  private static func freePort() -> UInt16 {
    var port = UInt16.random(in: 1025...65535)

    let socketFD = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
    if socketFD == -1 {
      return port
    }

    var hints = addrinfo(
      ai_flags: AI_PASSIVE,
      ai_family: AF_INET,
      ai_socktype: SOCK_STREAM,
      ai_protocol: 0,
      ai_addrlen: 0,
      ai_canonname: nil,
      ai_addr: nil,
      ai_next: nil
    )

    var addressInfo: UnsafeMutablePointer<addrinfo>? = nil
    var result = getaddrinfo(nil, "0", &hints, &addressInfo)
    if result != 0 {
      close(socketFD)

      return port
    }

    result = Darwin.bind(socketFD, addressInfo!.pointee.ai_addr, socklen_t(addressInfo!.pointee.ai_addrlen))
    if result == -1 {
      close(socketFD)

      return port
    }

    result = Darwin.listen(socketFD, 1)
    if result == -1 {
      close(socketFD)

      return port
    }

    var addr_in = sockaddr_in()
    addr_in.sin_len = UInt8(MemoryLayout.size(ofValue: addr_in))
    addr_in.sin_family = sa_family_t(AF_INET)

    var len = socklen_t(addr_in.sin_len)
    result = withUnsafeMutablePointer(to: &addr_in, {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        return Darwin.getsockname(socketFD, $0, &len)
      }
    })

    if result == 0 {
      port = addr_in.sin_port
    }

    Darwin.shutdown(socketFD, SHUT_RDWR)
    close(socketFD)

    return port
  }

}
