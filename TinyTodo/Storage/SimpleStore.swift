//
//  SimpleStore.swift
//  Workout
//
//  Created by Tyler Schultz on 1/31/22.
//

import Foundation
import Combine
/// Protocol representing the model used in the store
public protocol Model: Identifiable & Codable where ID: Codable {

}

/// Protocol representing the data store for the models
public protocol ModelStore {
  associatedtype T: Model

  func insert(_ value: T)
  func insert(_ values: [T])
  func update(_ value: T, forKey key: T.ID)
  func value(forKey key: T.ID) -> T?
  func values() -> [T]
  func removeValue(forKey key: T.ID)
  func removeAll()
  func save()
}

/// Concrete class using `Cache` as the underlying storage. It's intended to provide the basic
/// functionality of interfacing with the `Cache` library.
public class SimpleStore<V: Model>: ModelStore, ObservableObject {
  typealias Key = V.ID

  let filename: String
  let cache: Cache<Key, V>

  let dir: URL = {
    let url = try? FileManager.default.url(
      for: .cachesDirectory,
         in: .userDomainMask,
         appropriateFor: nil,
         create: true
    )
    return url ?? FileManager.default.temporaryDirectory
  }()

  init(filename: String) {
    self.filename = filename
    let cache = try? Cache<Key, V>.loadFromDisk(for: filename, at: dir)
    self.cache = cache ?? Cache<Key, V>()
  }

  public func insert(_ value: V) {
    cache.insert(value, forKey: value.id)
  }

  public func insert(_ values: [V]) {
    values.forEach(insert)
  }

  public func update(_ value: V, forKey key: V.ID) {
    do { try cache.update(value, forKey: key) }
    catch { print(error) }
  }

  public func value(forKey key: V.ID) -> V? {
    cache.value(forKey: key)
  }

  public func values() -> [V] {
    cache.allValues()
  }

  public func removeValue(forKey key: V.ID) {
    cache.removeValue(forKey: key)
  }

  public func removeAll() {
    cache.removeAll()
  }

  public func save() {
    do { try cache.saveToDisk(as: filename, at: dir) }
    catch { print(error) }
  }
}
