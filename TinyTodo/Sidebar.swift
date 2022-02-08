//
//  Sidebar.swift
//  TinyTodo
//
//  Created by Tyler Schultz on 2/7/22.
//

import SwiftUI

struct Sidebar: View {
  @EnvironmentObject var store: Store

    var body: some View {
      NavigationView {
        List {
          NavigationLink(destination: TodayView()) {
            Label("Today", systemImage: "star.fill")
          }
        }
      }
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
    }
}
