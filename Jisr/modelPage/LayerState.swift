//
//  LayerState.swift
//  Jisr
//
//  Created by Sarah Alnasser on 07/06/2026.
//
//  manages layer count and progress logic.
//  عدد الطبقات والتخزين المحلي ومنطق التقدم

import Foundation
import Combine

// Tracks how many bridge layers the user has earned and saves that count to UserDefaults.
final class LayerState: ObservableObject {
    static let maxLayers = 18

    // Current layer count. saved to UserDefaults on every change.
    @Published var layerCount: Int {
        didSet { UserDefaults.standard.set(layerCount, forKey: Keys.layerCount) }
    }

    // MARK: Private Storage Keys

    private enum Keys {
        static let layerCount    = "layerCount"
        static let lastAddedDate = "lastLayerAddedDate"
        static let creditedRooms = "creditedRoomCodes"
    }

    // A layer expires if no new one was added within (3 days).
    private let expiryInterval: TimeInterval = 3 * 24 * 3600

    // MARK: Computed Properties

    // Motivational message
    var motivationalText: String {
        switch layerCount {
        case 0:       return "Start building!"
        case 1...4:   return "Great start!"
        case 5...11:  return "Keep up the good work!"
        case 12...17: return "Almost there!"
        default:      return "You did it!"
        }
    }

    init() {
        self.layerCount = UserDefaults.standard.integer(forKey: Keys.layerCount)
        checkWeeklyExpiry()
    }

    // MARK: - Public Methods

    // gives one layer for each new completed room. Safe to call multiple times — each room is counted only once.
    func syncWithRooms(_ rooms: [Room], maxLayers: Int = LayerState.maxLayers) {
        var credited = Set(UserDefaults.standard.stringArray(forKey: Keys.creditedRooms) ?? [])
        var changed = false

        for room in rooms {
            let photoCount = room.photos?.count ?? 0
            guard room.maxPhotos > 0,
                  photoCount >= room.maxPhotos,
                  !credited.contains(room.code) else { continue }

            if layerCount < maxLayers {
                layerCount += 1
                UserDefaults.standard.set(Date(), forKey: Keys.lastAddedDate)
            }
            credited.insert(room.code)
            changed = true
        }

        if changed {
            UserDefaults.standard.set(Array(credited), forKey: Keys.creditedRooms)
        }
    }

    // Removes one layer if the expiry window has passed since the last addition.
    func checkWeeklyExpiry(maxLayers: Int = LayerState.maxLayers) {
        guard layerCount > 0, layerCount < maxLayers else { return }
        guard let lastDate = UserDefaults.standard.object(forKey: Keys.lastAddedDate) as? Date else {
            UserDefaults.standard.set(Date(), forKey: Keys.lastAddedDate)
            return
        }
        if Date().timeIntervalSince(lastDate) >= expiryInterval {
            layerCount = Swift.max(0, layerCount - 1)
            UserDefaults.standard.set(Date(), forKey: Keys.lastAddedDate)
        }
    }
}

