//
//  JisrApp.swift
//  Jisr
//
//  Created by Sarah on 23/11/1447 AH.
//

import SwiftUI
import SwiftData
import CloudKit

@main
struct JisrApp: App {
    @StateObject private var layerState = LayerState()
    
    let container: ModelContainer = {
        let schema = Schema([User.self, Room.self, Photo.self, RoomParticipant.self])
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .automatic
        )
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(layerState)
        }
        .modelContainer(container)
    }
}
