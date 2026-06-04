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
    @StateObject private var layerState = LayerState()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(layerState)
        }
        .modelContainer(for: [User.self, Room.self, Photo.self ,RoomParticipant.self])
    }
}

