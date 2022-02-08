import Foundation

private class WrappedStorage<Key: Hashable, Value> {
  private var dictionary: [Key: Value] = [:]

  func setObject(_ value: Value, forKey key: Key) {
    dictionary[key] = value
  }

  func object(forKey key: Key) -> Value? {
    dictionary[key]
  }

  func objects() -> [Value] {
    Array(dictionary.values)
  }

  func removeObject(forKey key: Key) {
    dictionary.removeValue(forKey: key)
  }

  func removeAllObjects() {
    dictionary.removeAll()
  }
}

public final class Cache<Key: Hashable, Value> {
  private let wrapped = WrappedStorage<Key, Entry>()
  private let dateProvider: () -> Date
  let entryLifetime: TimeInterval

  public init(dateProvider: @escaping () -> Date = Date.init,
              entryLifetime: TimeInterval = 24 * 60 * 60) {
    self.dateProvider = dateProvider
    self.entryLifetime = entryLifetime
  }

  public func insert(_ value: Value, forKey key: Key) {
    let date = dateProvider().addingTimeInterval(entryLifetime)
    let entry = Entry(key: key, value: value, expirationDate: date)
    wrapped.setObject(entry, forKey: key)
  }

  public func value(forKey key: Key) -> Value? {
    guard let entry = wrapped.object(forKey: key) else {
      return nil
    }

    guard dateProvider() < entry.expirationDate else {
      // Discard values that have expired
      removeValue(forKey: key)
      return nil
    }

    return entry.value
  }

  public func allValues() -> [Value] {
    wrapped.objects().map({ $0.value })
  }

  public func removeValue(forKey key: Key) {
    wrapped.removeObject(forKey: key)
  }

  public func removeAll() {
    wrapped.removeAllObjects()
  }
}

private extension Cache {
  enum CodingKeys: String, CodingKey {
    case entryLifetime
    case entries
  }
}

private extension Cache {
  final class Entry {
    let key: Key
    let value: Value
    let expirationDate: Date

    init(key: Key, value: Value, expirationDate: Date) {
      self.key = key
      self.value = value
      self.expirationDate = expirationDate
    }
  }
}

extension Cache {
  subscript(key: Key) -> Value? {
    get { return value(forKey: key) }
    set {
      guard let value = newValue else {
        // If nil was assigned using our subscript,
        // then we remove any value for that key:
        removeValue(forKey: key)
        return
      }

      insert(value, forKey: key)
    }
  }
}

private extension Cache {
  func insert(_ entry: Entry) {
    wrapped.setObject(entry, forKey: entry.key)
  }
}

extension Cache.Entry: Codable where Key: Codable, Value: Codable {}

extension Cache: Codable where Key: Codable, Value: Codable {
  convenience public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let entryLifetime = try container.decode(TimeInterval.self, forKey: .entryLifetime)
    self.init(entryLifetime: entryLifetime)


    let entries = try container.decode([Entry].self, forKey: .entries)
    entries.forEach(insert)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(entryLifetime, forKey: .entryLifetime)
    try container.encode(wrapped.objects(), forKey: .entries)
  }
}

@available(iOS 10.0, *)
@available(OSX 11.0, *)
extension Cache where Key: Codable, Value: Codable {

  public enum UpdateOptions: String, Option {
    // Treats empty arrays of the incoming value as nil so that the empty value doesn't replace
    // the existing value.
    case ignoreIncomingEmptyArrays
  }

  // MARK: - Disk

  public func saveToDisk(
    as name: String,
    at folderURL: URL = FileManager.default.temporaryDirectory,
    options: Data.WritingOptions = [.atomic, .completeFileProtectionUnlessOpen]
    ) throws {
    let fileURL = folderURL.appendingPathComponent(name + ".cache")
    let data = try JSONEncoder().encode(self)
    try data.write(to: fileURL, options: options)
  }

  public class func loadFromDisk(
    for name: String,
    at folderURL: URL = FileManager.default.temporaryDirectory
    ) throws -> Self {
    let fileURL = folderURL.appendingPathComponent(name + ".cache")
    let data = try Data(contentsOf: fileURL)
    return try JSONDecoder().decode(self, from: data)
  }

  public func update(_ value: Value, forKey key: Key, options: Set<UpdateOptions> = []) throws {
    guard let obj = self.value(forKey: key) else {
      insert(value, forKey: key)
      return
    }

    var dict1 = try obj.asDictionary()
    var dict2 = try value.asDictionary()

    if options.contains(.ignoreIncomingEmptyArrays) {
      for (key, val)in dict2 {
        if let arr = val as? Array<Any>, arr.isEmpty {
          dict2[key] = nil
        }
      }
    }

    dict1.merge(dict2, uniquingKeysWith: { $1 })

    let data = try dict1.asData()
    let newObj = try JSONDecoder().decode(Value.self, from: data)
    insert(newObj, forKey: key)
  }

}
