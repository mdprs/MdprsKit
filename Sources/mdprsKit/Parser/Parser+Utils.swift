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

fileprivate let SlideSeparator = "✄✄✄"
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
      return "\n\(SlideSeparator)\n"
    }
  ])
}()

fileprivate func keepMarkdown(html: String, markdown: Substring) -> String {
  let result = markdown.starts(with: "\n") ? "\(String(markdown))\n" : "\n\(String(markdown))\n"
  return result
}

public extension Parser {
  static func slideCount(in slidedeck: String) -> Int {
    let md = markdownParser.parse(slidedeck)
    let slideCount = md.html.count(of: SlideSeparator)

    return slideCount
  }

  static func slide(of line: Int, in slidedeck: String) -> Int? {
    // TODO This implementation needs some improvement, since the performance is poor.
    let md = markdownParser.parse(slidedeck)
    let headerLineCount = md.metadata.count > 0 ? md.metadata.count + 2 : 0

    guard line > headerLineCount else {
      // line number is within the header area
      return 1
    }

    let lines = slidedeck.components(separatedBy: "\n").dropFirst(headerLineCount)
    let correctedLine = line - headerLineCount
    var slideNum = 1
    var currentLine = 1
    var inCodeblock = false

    for line in lines {
      if currentLine == correctedLine {
        return slideNum
      }

      if line.starts(with: "```") {
        inCodeblock = !inCodeblock
      }

      if !inCodeblock && line == "---" {
        slideNum += 1
      }
      currentLine += 1
    }

    return slideNum
  }
}
