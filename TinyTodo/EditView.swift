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
      VStack {
        Text("Edit")
          .font(.title)
          .frame(alignment:.center)

        VStack(alignment: .leading) {
          Text("Title")
            .font(.caption)
          TextField("Title", text: $todo.title, prompt: nil)
        }.padding().background(.thinMaterial)
          .cornerRadius(12.0)

        VStack(alignment: .leading) {
          Text("Description")
            .font(.caption)
          TextField("Content", text: $todo.content, prompt: nil)
        }.padding()
          .background(.thinMaterial)
          .cornerRadius(12.0)


        VStack(alignment: .leading) {
          Text("Link")
            .font(.caption)
          TextField("Link", text: $link, prompt: nil)
        }.padding()
          .background(.thinMaterial)
          .cornerRadius(12.0)

        Toggle("Toggle", isOn: $todo.complete)
        HStack {
          Button(action: {
            dismiss()
          }) {
            Text("dismiss")
          }

          Button(action: {
            delete()
          }) {
            Text("delete")
          }
        }
        Spacer()
      }.onChange(of: todo) { newValue in
        store.insert(newValue)
      }.onChange(of: link) { newValue in
        todo.link = newValue
      }.padding()
        .onAppear {
          link = todo.link ?? ""
        }

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
