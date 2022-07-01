//
//  ParserSpec.swift
//  mdprsKitTests
//
//  Created by Thomas Bonk on 25.06.22.
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

@testable import mdprsKit

final class ParserSpec: QuickSpec {

  override func spec() {

    describe("Parsing a simple slide deck") {
      let parser = Parser()
      let url = Bundle.module.url(forResource: "testdata/simple_slidedeck.md", withExtension: nil)
      let markdown = try! String(contentsOf: url!)
      var presentation: Presentation?

      it("Parsing the slide deck is successful") {
        presentation = parser.parse(markdown: markdown)
      }

      it("The slide deck has been parsed successfully") {
        expect(presentation!.slides.count).to(equal(3))

        for i in 1...3 {
          expect(presentation!.slides[i - 1]).to(equal("<h1>Slide \(i)</h1>"))
        }
      }
    }

    describe("Parsing a slide deck with speaker notes") {
      let parser = Parser()
      let url = Bundle.module.url(forResource: "testdata/slidedeck_with_notes.md", withExtension: nil)
      let markdown = try! String(contentsOf: url!)
      var presentation: Presentation?

      it("Parsing the slide deck is successful") {
        presentation = parser.parse(markdown: markdown)
      }

      it("The slide deck has been parsed successfully and the speaker notes are available") {
        expect(presentation!.slides.count).to(equal(2))

        let speakerNotes = presentation!.slides[0].substrings(between: "<aside>", and: "</aside>")
        expect(speakerNotes.count).to(equal(1))
        expect(String(speakerNotes[0])).to(equal("<p>This are the speaker notes:</p><ul><li>item 1</li><li>item 2</li></ul>"))
      }

      it("The slide deck is rendered successfully") {
        let html = try presentation!.render()
        let slides = html.substrings(between: "<section>", and: "</section>")

        expect(slides.count).to(equal(2))
      }
    }

  }
}
