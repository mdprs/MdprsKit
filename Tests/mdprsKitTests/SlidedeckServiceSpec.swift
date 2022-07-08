//
//  SlidedeckServiceSpec.swift
//  mdprsKitTests
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

import Foundation
import Quick
import Nimble
import Sweep
import XCTest

@testable import mdprsKit

final class SlidedeckServiceSpec: QuickSpec {

  override func spec() {

    describe("Serving a slide deck") {
      let parser = Parser()
      let url = Bundle.module.url(forResource: "testdata/simple_slidedeck.md", withExtension: nil)
      let markdown = try! String(contentsOf: url!)
      var presentation: Presentation?
      let service = SlidedeckService()
      var serverTask: Task<Void, Error>!

      it("Starting the service is successful") {
        serverTask = Task {
          try service.start()
        }
      }

      it("Parsing the markdown is success full") {
        presentation = parser.parse(markdown: markdown)
      }

      it("Rendering the slide deck and serving the updated version is successful") {
        var html = ""
        let expectation = XCTestExpectation(description: "Retrieve slide deck")

        service.slidedeck = try presentation!.render()

        let url = URL(string: "http://localhost:\(service.port)/")!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
          guard let data = data else { return }
          html = String(data: data, encoding: .utf8)!
          expectation.fulfill()
        }

        task.resume()

        self.wait(for: [expectation], timeout: 10.0)

        let slides = html.substrings(between: "<section>", and: "</section>")
        expect(slides.count).to(equal(3))

        serverTask.cancel()
      }

      it("Reading a file from dist directory") {
        var mimeType: String? = nil
        var fileData: Data? = nil
        let expectation = XCTestExpectation(description: "Retrieve dist file")

        let url = URL(string: "http://localhost:\(service.port)/dist/theme/beige.css")!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
          mimeType = response?.mimeType
          fileData = data
          expectation.fulfill()
        }

        task.resume()

        self.wait(for: [expectation], timeout: 10.0)

        expect(mimeType).to(equal("text/css"))
        expect(fileData).toNot(beNil())
        expect(fileData!.count).to(beGreaterThan(0))

        serverTask.cancel()
      }

    }
  }

}
