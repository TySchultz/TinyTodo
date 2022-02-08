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
  var body: some View {
    list
    .sheet(item: $editTodo, onDismiss: nil, content: { item in
      EditView(todo: item)
    })
    .sheet(isPresented: $showSettings, content: {
      Settings()
    })
    .onChange(of: store.type, perform: { newValue in
      update()
    })
    .onChange(of: store.didUpdate, perform: { newValue in
      withAnimation {
        update()
      }
    })
    .onAppear {
      update()
    }.navigationTitle(formattedDate())
      .toolbar {
        ToolbarItem(placement: .bottomBar) {
          Button(action: {
            showSettings.toggle()
          }) {
            Label("Settings", systemImage: "gear")
          }.tint(.primary)
        }
        ToolbarItem(placement: .bottomBar) {
          Button(action: {
            print("Calendar")
          }) {
            Label("Calendar", systemImage: "calendar")
          }.tint(.primary)
        }
        ToolbarItem(placement: .bottomBar) {
          Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
          Button(action: {
            addRow()
          }) {
            Label("Add", systemImage: "plus.app")
          }.tint(.primary)
        }
      }
  }
}

// - MARK: UI
extension TodayView {

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
    VStack(spacing: 0) {
      ForEach(allItems.filter({$0.complete == false}), id: \.self) { todo in
        HStack {
          TodoRow(todo: todo)
            .contentShape(Rectangle())
            .onTapGesture {
              toggle(todo: todo)
            }.contextMenu {
              Button {
                editTodo = todo
              } label: {
                Label("Edit", systemImage: "pencil.and.outline")
              }

              Button {
                remove(todo)
              } label: {
                Label("Delete", systemImage: "pencil.and.outline")
              }
            }
          Button(action: {
            editTodo = todo
          }) {
            Text("View")
          }
          .padding(.vertical, 6)
          .padding(.horizontal)
          .buttonStyle(PlainButtonStyle())
          .font(.subheadline)
          .foregroundColor(.blue)
          .background(Capsule(style: .continuous).foregroundColor(Color(UIColor.systemBackground)))
        }.padding(.trailing)
      }.transition(.scale)

    }.background(.ultraThinMaterial)
      .cornerRadius(12.0).padding()
  }

  var completeGroup: some View {
    VStack(spacing: 0) {
      ForEach(allItems.filter({$0.complete}).sorted(by: {$0.modifiedDate > $1.modifiedDate}), id: \.self) { todo in
        TodoRow(todo: todo)
          .contentShape(Rectangle())
          .onTapGesture {
            toggle(todo: todo)
          }.onLongPressGesture {
            editTodo = todo
          }
      }.transition(.scale)
    }.cornerRadius(12.0).padding()
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

  func toggle(todo: Todo) {
    withAnimation {
      store.toggleComplete(todo)
    }
  }

  func remove(_ todo: Todo) {
      store.remove(with: todo.id)
  }

  func update() {
//    withAnimation {
      allItems = store.allValues().sorted(by: {$0.modifiedDate < $1.modifiedDate})
//    }
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
