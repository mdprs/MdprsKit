//
//  Parser.swift
//  mdprsKit
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
import Ink
import Sweep

public class Parser {

  // MARK: - Initialization

  public init() {
    markdownParser = MarkdownParser()
    markdownParser
      .addModifier(
        Modifier(
          target: .horizontalLines,
          closure: addSlideSplitter(html:markdown:)))
  }


  // MARK: - Private Constants

  internal static let SlideSplitter = "<!-- SLIDE_SPLITTER -->"


  // MARK: - Private Properties

  private var markdownParser: MarkdownParser


  // MARK: - Public Methods

  public func parse(markdown: String) -> Presentation {
    let md = markdownParser.parse(markdown)
    let content = md.html

    return Presentation(
      metadata: Metadata(from: md.metadata.nonStyles),
      styles: md.metadata.styles,
      slides: content
        .components(separatedBy: Parser.SlideSplitter)
        .map { content -> Slide in
          Slide(content: processSpeakerNotes(slide: content))
        })
  }


  // MARK: - Private Methods

  private func addSlideSplitter(html: String, markdown: Substring) -> String {
    return Parser.SlideSplitter
  }

  private func processSpeakerNotes(slide: String) -> String {
    var slideWithNotes = slide
    let speakerNotesMd = slide.substrings(between: "<!-- NOTES", and: "-->")
    let speakerNotesHtml = speakerNotesMd.map({ "<aside>\(markdownParser.parse(String($0)).html)</aside>" })

    for i in 0..<speakerNotesMd.count {
      slideWithNotes = slideWithNotes.replacingOccurrences(of: "<!-- NOTES\(speakerNotesMd[i])-->", with: speakerNotesHtml[i])
    }

    return slideWithNotes
  }
}

fileprivate extension Dictionary {
  var nonStyles: [String:String] {
    var result: [String:String] = [:]

    self.keys.forEach { key in
      if let k = key as? String {
        if !k.starts(with: "style-") {
          result[k] = self[key] as? String
        }
      }
    }

    return result
  }

  var styles: [String:String] {
    var result: [String:String] = [:]

    self.keys.forEach { key in
      if let k = key as? String {
        if k.starts(with: "style-") {
          result[k.replacingOccurrences(of: "style-", with: "")] = self[key] as? String
        }
      }
    }

    return result
  }
}
