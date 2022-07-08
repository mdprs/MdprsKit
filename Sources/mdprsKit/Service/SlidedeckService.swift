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
  public private(set) var isRunning = false


  // MARK: - Private Properties

  private let server = HttpServer()
  private var webSocketSessions = [WebSocketSession]()
  private let parser = Parser()


  // MARK: - Initialization

  public init() {
    configure(server)
  }

  deinit {
    stop()
  }


  // MARK: - Public Methods

  public func start() throws {
    try server.start(self.port, forceIPv4: true, priority: .background)
    isRunning = true
  }

  public func stop() {
    guard !isRunning else {
      return
    }

    server.stop()
    isRunning = false
  }


  // MARK: - Private Methods

  private func configure(_ server: HttpServer) {
    server.listenAddressIPv4 = "0.0.0.0"

    server["/"] = renderSlideDeck(request:)
    exposeBundledFiles(to: server)
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

      return .ok(.html(html))
    } catch {
      return .internalServerError
    }
  }

  private func exposeBundledFiles(to server: HttpServer) {
    let bundledResourcesPath = Bundle.module.path(forResource: "reveal.js", ofType: "")!

    exposeBundledFiles(from: bundledResourcesPath, pathPrefix: "/", to: server)
  }

  private func exposeBundledFiles(from basePath: String, pathPrefix: String, to server: HttpServer) {
    if let folder = try? Folder(path: basePath) {
      folder.files.forEach { file in
        if file.extension != "stencil" {
          let resource = "reveal.js".appendingPathComponent(pathPrefix).appendingPathComponent(file.name)
          let url = Bundle.module.url(forResource: resource, withExtension: "")!

          server[pathPrefix.appendingPathComponent(file.name)] = { (HttpRequest) -> HttpResponse in
            do {
              let data = try Data(contentsOf: url)
              let mimeType = self.mimeType(data: data, pathExtension: url.pathExtension)

              return .ok(.data(data, contentType: mimeType))
            } catch {
              return .notFound
            }
          }
        }
      }

      folder.subfolders.forEach { folder in
        exposeBundledFiles(
          from: basePath.appendingPathComponent(folder.name),
          pathPrefix: pathPrefix.appendingPathComponent(folder.name),
          to: server)
      }
    }
  }

  private func mimeType(data: Data, pathExtension: String) -> String? {
    let mimeType = Swime.mimeType(data: data)

    if mimeType == nil || mimeType?.mime == "text/plain" {
      switch pathExtension {
        case "css":
          return "text/css"

        case "js":
          return "text/javascript"

        default:
          return mimeType?.mime
      }
    }

    return mimeType?.mime
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
