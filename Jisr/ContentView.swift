//
//  ContentView.swift
//  Jisr
//
//  Created by Sarah on 23/11/1447 AH.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NameView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, Room.self, Photo.self], inMemory: true)
}

//#Preview {
//    ContentView()
//        .modelContainer(for: User.self, inMemory: true)
//}
