//
//  ContentView.swift
//  TinyTodo
//
//  Created by Tyler Schultz on 2/3/22.
//

import SwiftUI
import Combine

struct TodayView: View {
  @EnvironmentObject var store: Store
  @State private var animationAmount = 1.0
  @State var allItems: [Todo] = []
  @State var editTodo: Todo?
  @State private var cancellable: AnyCancellable?
  @State var showSettings: Bool = false
  @State var showCalendar: Bool = false
  var body: some View {
    list
    .sheet(item: $editTodo, onDismiss: nil, content: { item in
      EditView(todo: item)
    })
    .sheet(isPresented: $showSettings, content: {
      Settings()
    })
    .navigationTitle(formattedDate())
      .toolbar {
        settingsButton
        backwardButton
        forwardButton
        toolbarDate
        ToolbarItem(placement: .bottomBar) {
          Spacer()
        }
        addButton
      }
  }
}

// - MARK: UI
extension TodayView {
  var settingsButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Button(action: {
        showSettings.toggle()
      }) {
        Label("Settings", systemImage: "gear")
      }.tint(.primary)
    }
  }
  var backwardButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Button(action: {
        store.changeDate(direction: .backwards)
      }) {
        Label("Back A Day", systemImage: "chevron.left")
      }.tint(.primary)
    }
  }
  var forwardButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Button(action: {
        store.changeDate(direction: .forward)
      }) {
        Label("Forward A Day", systemImage: "chevron.right")
      }.tint(.primary)
    }
  }
  var toolbarDate: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Text(store.currentDateFormatted())
    }
  }

  var addButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Button(action: {
        addRow()
      }) {
        Label("Add", systemImage: "plus.app")
      }.tint(.primary)
    }
  }

  var list: some View {
    ScrollView {
      VStack(spacing: 0) {
        todoGroup
        completeGroup
        Spacer()
      }.padding(.vertical)
    }.transition(.scale)
  }

  var todoGroup: some View {
    ActiveList(editTodo: self.$editTodo)
  }

  var completeGroup: some View {
    CompleteList(editTodo: self.$editTodo)
  }

  var toolbar: some View {
    HStack {
      Picker("View", selection: $store.type) {
        ForEach(TodoListType.allCases, id: \.self) { type in
          Text(type.displayText()).tag(type.rawValue).badge(3)
        }
      }.pickerStyle(.inline)

      Button(action: addRow) {
        Label("Add", systemImage: "plus.app")
      }
    }.padding()
  }
}


// - MARK: Utilities
extension TodayView {

  func addRow() {
     editTodo = Todo(id: UUID().uuidString, title: "", content: "", complete: false)
  }

  func formattedDate() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "eeee - MMMM dd, YYYY"
    return formatter.string(from: Date())
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    TodayView()
  }
}
