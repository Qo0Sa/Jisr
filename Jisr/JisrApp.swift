//
//  JisrApp.swift
//  Jisr
//
//  Created by Sarah on 23/11/1447 AH.
//

import SwiftUI
import SwiftData

@main
struct JisrApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(for: [User.self, Room.self, Photo.self])
    }
}

