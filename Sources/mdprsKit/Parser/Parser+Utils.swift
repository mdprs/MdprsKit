//
//  Parser+Utils.swift
//  mdprsKit
//
//  Created by Thomas Bonk on 08.07.22.
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

fileprivate var markdownParser: MarkdownParser = {
  return MarkdownParser(modifiers: [
    Modifier(target: .html, closure: keepMarkdown),
    Modifier(target: .blockquotes, closure: keepMarkdown),
    Modifier(target: .codeBlocks, closure: keepMarkdown),
    Modifier(target: .headings, closure: keepMarkdown),
    Modifier(target: .images, closure: keepMarkdown),
    Modifier(target: .inlineCode, closure: keepMarkdown),
    Modifier(target: .links, closure: keepMarkdown),
    Modifier(target: .lists, closure: keepMarkdown),
    Modifier(target: .paragraphs, closure: keepMarkdown),
    Modifier(target: .tables, closure: keepMarkdown),

    Modifier(target: .horizontalLines) { _, _ in
      return Parser.SlideSplitter
    }
  ])
}()

fileprivate func keepMarkdown(html: String, markdown: Substring) -> String {
  let result = "\(String(markdown))\n"
  return result
}

public extension Parser {
  static func slide(of line: Int, in slidedeck: String) -> Int? {
    let md = markdownParser.parse(slidedeck)
    let headerLineCount = md.metadata.count > 0 ? md.metadata.count + 2 : 0

    guard line > headerLineCount else {
      // line number is within the header area
      return 1
    }

    let correctedLine = line - headerLineCount
    let slides = md.html.components(separatedBy: Parser.SlideSplitter)
    var slideLineOffset = 1
    var slideNum = 0

    for i in 0..<slides.count {
      let slideLineCount = slides[i].count(of: "\n") + 1

      if slideLineOffset <= correctedLine && correctedLine <= slideLineOffset + slideLineCount + 1 {
        return i + 1
      }

      slideNum = i
      slideLineOffset = slideLineCount + 1
    }

    return slideNum + 1
  }
}
