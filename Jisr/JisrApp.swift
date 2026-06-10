//
//  JisrApp.swift
//  Jisr
//
//  Created by Sarah on 23/11/1447 AH.
//

import SwiftUI
import SwiftData
import CloudKit
import UserNotifications


extension Notification.Name {
    static let cloudKitDataChanged = Notification.Name("cloudKitDataChanged")
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        NotificationCenter.default.post(name: .cloudKitDataChanged, object: notification)
        completionHandler(.newData)
    }
}


@main
struct JisrApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var layerState = LayerState()
    
    let container: ModelContainer = {
        let schema = Schema([User.self, Room.self, Photo.self, RoomParticipant.self])
        let cloudConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        if let container = try? ModelContainer(for: schema, configurations: cloudConfig) {
            return container
        }
        let localConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, configurations: localConfig)
        } catch {
            fatalError("Failed to create local container: \(error)")
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
