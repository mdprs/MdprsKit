//
//  Metadata.swift
//  mdprsKit
//
//  Created by Thomas Bonk on 27.06.22.
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

public struct Metadata {

  // MARK: - Public Properties

  public let title: String
  public let author: String
  public let description: String
  public let language: String
  public let theme: String


  // MARK: - Initialization

  public init(from dictionary: [String : String]) {
    self.title = dictionary["title"] ?? ""
    self.author = dictionary["author"] ?? ""
    self.description = dictionary["description"] ?? ""
    self.language = dictionary["language"] ?? "en"
    self.theme = dictionary["theme"] ?? "white"
  }
}
