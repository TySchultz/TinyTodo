//
//  EditView.swift
//  TinyTodo
//
//  Created by Tyler Schultz on 2/4/22.
//

import SwiftUI

struct EditView: View {
  @EnvironmentObject var store: Store

  @Environment(\.dismiss) private var dismiss
  @State var link: String = ""

  @State var todo: Todo
  
  var body: some View {
    List {
      Text("Create New Todo")
        .font(.title)
        .frame(alignment:.center)
        .listRowSeparator(.hidden)
        .padding()

      VStack(alignment: .leading) {
        Text("Title")
          .font(.caption)
        TextField("Title", text: $todo.title, prompt: nil)
      }.padding().background(.thinMaterial)
        .cornerRadius(12.0)
        .listRowSeparator(.hidden)

      VStack(alignment: .leading) {
        Text("Description")
          .font(.caption)
        TextField("Content", text: $todo.content, prompt: nil)
      }.padding()
        .background(.thinMaterial)
        .cornerRadius(12.0)
        .listRowSeparator(.hidden)


      VStack(alignment: .leading) {
        Text("Link")
          .font(.caption)
        TextField("Link", text: $link, prompt: nil)
      }.padding()
        .background(.thinMaterial)
        .cornerRadius(12.0)
        .listRowSeparator(.hidden)

      Toggle("Complete", isOn: $todo.complete)
      Button(action: {
        store.insert(todo)
        dismiss()
      }) {
        Text("Create")
      }.buttonStyle(BorderedProminentButtonStyle())
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)

      Button(action: {
        delete()
      }) {
        Text("Delete")
      }.buttonStyle(BorderedButtonStyle())
        .frame(maxWidth: .infinity)
      .listRowSeparator(.hidden)
    }.onChange(of: link) { newValue in
      todo.link = newValue
    }
    .onAppear {
      link = todo.link ?? ""
    }.listStyle(PlainListStyle())
  }

  func delete() {
    store.remove(with: todo.id)
    dismiss()
  }
}

struct EditView_Previews: PreviewProvider {
  static var previews: some View {
    EditView(todo: Todo(id: "1", title: "testing", content: "1", complete: false))
  }
}
