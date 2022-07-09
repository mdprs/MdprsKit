//
//  String+ranges.swift
//  mdprsKit
//
//  Source: https://stackoverflow.com/a/40413663/44123
//

import Foundation

public extension String {
  func ranges(
    of needle: String,
    options: String.CompareOptions = [],
    range: Range<String.Index>? = nil,
    locale: Locale? = nil
  ) -> [Range<String.Index>] {

    // the slice within which to search
    let slice = (range == nil) ? self[...] : self[range!]

    var previousEnd = slice.startIndex
    var ranges = [Range<String.Index>]()

    while let r = slice.range(of: needle, options: options, range: previousEnd ..< slice.endIndex, locale: locale) {
      if previousEnd != self.endIndex { // don't increment past the end
        previousEnd = self.index(after: r.lowerBound)
      }
      ranges.append(r)
    }

    return ranges
  }

  func ranges(
    of aString: String,
    options: String.CompareOptions = [],
    range: Range<String.Index>? = nil,
    locale: Locale? = nil
  ) -> [Range<Int>] {
    return ranges(of: aString, options: options, range: range, locale: locale)
      .map(indexRangeToIntRange)
  }


  private func indexRangeToIntRange(_ range: Range<String.Index>) -> Range<Int> {
    return indexToInt(range.lowerBound) ..< indexToInt(range.upperBound)
  }

  private func indexToInt(_ index: String.Index) -> Int {
    return self.distance(from: self.startIndex, to: index)
  }
}
