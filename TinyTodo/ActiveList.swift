//
//  ActiveTodoList.swift
//  TinyTodo
//
//  Created by Tyler Schultz on 2/9/22.
//

import SwiftUI

struct ActiveList: View {
  @EnvironmentObject var store: Store

  @State var allItems: [Todo] = []
  @Binding var editTodo: Todo?
  var body: some View {
    VStack(spacing: 0) {
      ForEach(allItems, id: \.self) { todo in
        HStack {
          TodoRow(todo: todo)
            .contentShape(Rectangle())
            .onTapGesture {
              toggle(todo: todo)
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
      .onAppear {
        setup()
      }
      .onChange(of: store.didUpdate, perform: { newValue in
        withAnimation {
          update()
        }
      })
  }

  func setup() {
    update()
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
    allItems = store.allValues().filter({$0.complete == false}).sorted(by: {$0.modifiedDate < $1.modifiedDate})
  }

}

struct ActiveTodoList_Previews: PreviewProvider {
    static var previews: some View {
      ActiveList(editTodo: .constant(nil))
    }
}
