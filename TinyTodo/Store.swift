//
//  Store.swift
//  TinyTodo
//
//  Created by Tyler Schultz on 2/4/22.
//

import Foundation
import Combine

enum TodoListType: Int, CaseIterable {
  case work
  case home
  case app

  func displayText() -> String {
    switch self {
      case .work:
        return "Work"
      case .home:
        return "Home"
      case .app:
        return "App"
    }
  }

  func storeName() -> String {
    switch self {
      case .work:
        return "work.store"
      case .home:
        return "home.store"
      case .app:
        return "app.store"
    }
  }
}
class Store: ObservableObject {
  @Published var showModal: Bool = false
  @Published var todoStore: SimpleStore<Todo> = SimpleStore(filename: "todoStore")
  @Published var type: TodoListType = .work
  private var cancellable: AnyCancellable?

  init() {
    cancellable = $type.sink { newValue in
      print(newValue)
      self.todoStore = SimpleStore(filename: newValue.storeName())
    }
  }
}

// - MARK: Utility

extension Store {
  func clearData() {
    todoStore.removeAll()
  }


//  private func importJSON() {
//    guard UserDefaults.loadedJSON == false else {
//      return
//    }
//    UserDefaults.loadedJSON.toggle()
//    if let path = Bundle.main.path(forResource: "SingleJSON", ofType: "json") {
//      do {
//        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
//
//        let decoder = JSONDecoder()
//
//        do {
//          let jsonStore = try decoder.decode(jsonStore.self, from: data)
//          self.insert(jsonStore.weeks)
//          self.insert(jsonStore.days)
//          self.insert(jsonStore.exercises)
//        } catch {
//          print(error)
//        }
//      } catch {
//        // handle error
//      }
//    }
//  }

  func updateModifiedDate(_ todo: Todo, now: Date = Date()) -> Todo {
    var copy = todo
    copy.modifiedDate = now
    return copy
  }

}

// - MARK: Retrieve

extension Store {

  func todo(for id: String) -> Todo? {
    return todoStore.value(forKey: id)
  }

  func allValues() -> [Todo] {
    return todoStore.values()
  }
}

// - MARK: Insert

extension Store {

  func insert(_ todo: Todo) {

    todoStore.insert(updateModifiedDate(todo))
    todoStore.save()
  }
//
//  func insert(_ todos: [Todo]) {
//    todos.insert(todos)
//  }

}

// - Remove

extension Store {
  func remove(with id: String) {
    todoStore.removeValue(forKey: id)
    todoStore.save()
  }
}
