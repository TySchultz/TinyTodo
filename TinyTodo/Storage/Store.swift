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
  @Published var todoStore: SimpleStore<Todo> = SimpleStore<Todo>(filename: "todoStore")
  @Published var type: TodoListType = .work
  @Published var didUpdate: String = ""
  @Published var currentDate: Date = Date()

  private var cancellables: [AnyCancellable] = []
  private var storeCancel: AnyCancellable?

  init() {
    // Select the correct database
    cancellables.append($type.sink { newValue in
      self.todoStore = SimpleStore<Todo>(filename: newValue.storeName())
      self.publish()
    })

    cancellables.append($currentDate.sink(receiveValue: { newDate in
      self.publish()
    }))
  }

  func currentDateFormatted() -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "eeee - MMMM dd"
      return formatter.string(from: currentDate)
  }
}

// - MARK: Utility

enum DateDirection {
  case forward
  case backwards
}

extension Store {
  func changeDate(direction: DateDirection) {
    switch direction {
      case .forward:
        self.currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
      case .backwards:
        self.currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
    }
  }

  func clearData() {
    todoStore.removeAll()
  }

  func publish() {
    self.didUpdate = UUID().uuidString
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
    return todoStore.values().filter({ sameDays(lhs: $0.creationDate, rhs: self.currentDate) })
  }

  private func sameDays(lhs: Date, rhs: Date) -> Bool {
    return Calendar.current.isDate(lhs, inSameDayAs: rhs)
  }
}

// - MARK: Insert

extension Store {

  func insert(_ todo: Todo) {
    todoStore.insert(updateModifiedDate(todo))
    todoStore.save()
    publish()
  }

  func toggleComplete(_ todo: Todo) {
    var copy = todo
    copy.complete = !todo.complete
    todoStore.insert(updateModifiedDate(copy))
    todoStore.save()
    publish()
  }

}

// - Remove

extension Store {
  func remove(with id: String) {
    todoStore.removeValue(forKey: id)
    todoStore.save()
  }
}
