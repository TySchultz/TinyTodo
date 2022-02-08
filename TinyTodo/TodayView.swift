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

  @State var undoOption: Todo?

  @State var showingAllDays: Bool = false
  @State var homeView: Bool = false
  @State var workView: Bool = false
  @State var segmentedControl: Int = 0
  var body: some View {
      HStack {
        list
      }
      .sheet(item: $editTodo, onDismiss: {
        update()
      }, content: { item in
        EditView(todo: item)
      })
      .onChange(of: undoOption, perform: { newValue in
        hideTodo(newValue: newValue)
      })
      .onChange(of: store.type, perform: { newValue in
        update()
      })
      .onAppear {
        update()

      }.toolbar {
        ToolbarItem(placement: .bottomBar) {
          HStack {

            Picker("View", selection: $store.type) {
              ForEach(TodoListType.allCases, id: \.self) { type in
                Text(type.displayText()).tag(type.rawValue).badge(3)
              }
            }.pickerStyle(.segmented)
            Spacer()
            Button(action:  {
              addRow()
            }) {
              Label("Add", systemImage: "plus")
            }
          }

        }
      }.navigationTitle(formattedDate)
  }

  var list: some View {
    ScrollView {
      VStack(spacing: 0) {
        HStack {
          Spacer()
          if let undo = undoOption {
            Button(action: {
              withAnimation {
                store.insert(undo)
                undoOption = nil
                update()
              }
            }) {
              Label("Undo", systemImage: "arrow.uturn.backward")
            }
          }
        }
        todoGroup
        completeGroup
        Spacer()
      }.padding(.vertical)
    }.transition(.scale)
  }

  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "eeee - MMMM dd, YYYY"
    return formatter.string(from: Date())
  }


  func hideTodo(newValue: Todo?) {
    Task {
      do {
        print(newValue)
        guard newValue != nil else {
          return
        }
        try? await Task.sleep(nanoseconds: 2_500_000_000)
        withAnimation {
          undoOption = nil
        }
      } catch {
        print(error)
      }
    }

  }

var todoGroup: some View {
  VStack(spacing: 0) {
    ForEach(allItems.filter({$0.complete == false}), id: \.self) { todo in
//#if targetEnvironment(macCatalyst)
//
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
//#elseif os(iOS)
//
//      TodoRow(todo: todo)
//        .contentShape(Rectangle())
//        .onTapGesture {
//          toggle(todo: todo)
//        }.contextMenu {
//          Button {
//            editTodo = todo
//          } label: {
//            Label("Edit", systemImage: "pencil.and.outline")
//          }
//
//          Button {
//            remove(todo)
//          } label: {
//            Label("Delete", systemImage: "pencil.and.outline")
//          }
//        }
//#endif

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

func addRow() {
  editTodo = Todo(id: UUID().uuidString, title: "", content: "", complete: false)
}

func toggle(todo: Todo) {
  withAnimation {
    var copy = todo
    copy.complete = !todo.complete
    store.insert(copy)
    update()

  }
}


func remove(_ todo: Todo) {
  withAnimation {
    store.remove(with: todo.id)
    update()
    undoOption = todo
  }
}

func update() {
  allItems = store.allValues().sorted(by: {$0.modifiedDate < $1.modifiedDate})
}
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    TodayView()
  }
}
