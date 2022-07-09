//
//  Presentation.swift
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
import PathKit
import Stencil

public struct Presentation {

  // MARK: - Public Properties

  public let metadata: Metadata
  public let slides: [String]

  // MARK: - Private Properties

  private let loader: Loader!
  private let environment: Environment!

  private var context: [String: Any] {
    return [
      "title":  metadata.title,
      "author": metadata.author,
      "description": metadata.description,
      "language": metadata.language,
      "theme": metadata.theme,
      "center": metadata.center,
      "minscale": metadata.minscale,
      "maxscale": metadata.maxscale,
      "slides": slides
    ]
  }


  // MARK: - Initialization

  public init(metadata: Metadata, slides: [String]) {
    self.metadata = metadata
    self.slides = slides

    let templatePath = Bundle
      .module
      .url(forResource: "reveal.js/presentation.html.stencil", withExtension: "")!
      .deletingLastPathComponent()
      .path

    self.loader = FileSystemLoader(paths: [Path(templatePath)])
    self.environment = Environment(loader: loader)
  }


  // MARK: - Public Methods

  public func render() throws -> String {
    return try environment.renderTemplate(name: "presentation.html.stencil", context: context)
  }

}
