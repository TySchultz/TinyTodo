//
//  TodoRow.swift
//  TinyTodo
//
//  Created by Tyler Schultz on 2/4/22.
//

import SwiftUI

struct TodoRow: View {
    @State var todo: Todo
    var body: some View {
        HStack() {
          HStack {
            Image(systemName: todo.complete ? "checkmark.circle.fill" : "circle")
            VStack(alignment: .leading, spacing: 4) {
              Text(todo.title)
                .font(.headline)
              if todo.content != "" {
                Text(todo.content)
                  .foregroundColor(.secondary)
              }
            }
          }
          Spacer()
          if let link = todo.link, let url = URL(string: link) {
            Link(destination: url) {
              Image(systemName: "link")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
                .font(.largeTitle)

            }
          }

        }
        .foregroundColor(todo.complete ? .secondary : .primary)

      .padding()
    }
}

struct TodoRow_Previews: PreviewProvider {
    static var previews: some View {
      List {
        TodoRow(todo: Todo(id: "1", title: "testing", content: "Create Tiny Todo App Functionality", complete: false))
        TodoRow(todo: Todo(id: "2", title: "testing", content: "Create Tiny Todo App Functionality", complete: true))
      }
    }
}
