//
//  JisrApp.swift
//  Jisr
//

import SwiftUI
import SwiftData
import FirebaseCore
import UserNotifications

@main
struct JisrApp: App {
    @StateObject private var layerState = LayerState()

    init() {
        FirebaseApp.configure()
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    let container: ModelContainer = {
        let schema = Schema([User.self, Room.self, Photo.self, RoomParticipant.self])
        let localConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, configurations: localConfig)
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
