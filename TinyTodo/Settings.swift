//
//  Settings.swift
//  TinyTodo
//
//  Created by Tyler Schultz on 2/8/22.
//

import SwiftUI

struct Settings: View {
  @Environment(\.dismiss) private var dismiss

    var body: some View {
      List {
        Text("adfa")
        Button(action: {
            dismiss()
        }) {
          Text("Dismiss")
        }
      }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
