

import Foundation

extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}

extension Dictionary {
  func asData() throws -> Data {
    return try JSONSerialization.data(withJSONObject: self, options: [])
  }
}

/// https://nshipster.com/optionset/
protocol Option: RawRepresentable, Hashable, CaseIterable {}

extension Set where Element: Option {
  var rawValue: Int {
    var rawValue = 0
    for (index, element) in Element.allCases.enumerated() {
      if self.contains(element) {
        rawValue |= (1 << index)
      }
    }

    return rawValue
  }
}
