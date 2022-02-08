//
//  Model.swift
//  TinyTodo
//
//  Created by Tyler Schultz on 2/4/22.
//

import Foundation

struct Todo: Model, Codable, Hashable, Identifiable {
  var id: String
  var title: String
  var content: String
  var complete: Bool
  var creationDate: Date
  var modifiedDate: Date
  var link: String?

  init(id: String, title: String, content: String, complete: Bool = false) {
    self.id = id
    self.title = title
    self.content = content
    self.complete = complete
    let now = Date()
    self.creationDate = now
    self.modifiedDate = now
  }
}
