//
//  CloudKitManager.swift
//  Jisr
//
//  Created by Sarah on 24/12/1447 AH.
//

import Foundation
import CloudKit
import SwiftUI

class CloudKitManager {
    
    static let shared = CloudKitManager()
    private let publicDB = CKContainer.default().publicCloudDatabase
    
    var currentUserID: String {
        UserDefaults.standard.string(forKey: "iCloudUserID") ?? ""
    }
    
    // ─────────────────────────────────────────
    // MARK: - Room
    // ─────────────────────────────────────────
    
    func createRoom(name: String, code: String, category: String,
                    location: String, maxPhotos: Int,
                    missionTitle: String, missionDescription: String) async -> CKRecord? {
        let record = CKRecord(recordType: "CD_Room")
        record["CD_name"]               = name
        record["CD_code"]               = code
        record["CD_category"]           = category
        record["CD_location"]           = location
        record["CD_maxPhotos"]          = maxPhotos
        record["CD_isStarted"]          = 0
        record["CD_isClosed"]           = 0
        record["CD_missionTitle"]       = missionTitle
        record["CD_missionDescription"] = missionDescription
        record["CD_hostUserID"]         = currentUserID

        do {
            let saved = try await publicDB.save(record)
            print("✅ Room created: \(code)")
            return saved
        } catch {
            print("❌ createRoom: \(error)")
            return nil
        }
    }

    func fetchRoom(byCode code: String) async -> CKRecord? {
        let predicate = NSPredicate(format: "CD_code == %@", code)
        let query = CKQuery(recordType: "CD_Room", predicate: predicate)
        do {
            let result = try await publicDB.records(matching: query)
            return result.matchResults.compactMap { try? $0.1.get() }.first
        } catch {
            print("❌ fetchRoom: \(error)")
            return nil
        }
    }

    func updateRoom(recordID: CKRecord.ID, isStarted: Int? = nil, isClosed: Int? = nil) async {
        do {
            let record = try await publicDB.record(for: recordID)
            if let isStarted { record["CD_isStarted"] = isStarted }
            if let isClosed  { record["CD_isClosed"]  = isClosed  }
            try await publicDB.save(record)
            print("✅ Room updated")
        } catch {
            print("❌ updateRoom: \(error)")
        }
    }

    // ─────────────────────────────────────────
    // MARK: - Participants
    // ─────────────────────────────────────────

    func addParticipant(roomCode: String, userName: String,
                        profileImage: Data?, isHost: Bool) async -> CKRecord? {
        let record = CKRecord(recordType: "CD_RoomParticipant")
        record["CD_room"]     = roomCode
        record["CD_user"]     = currentUserID
        record["CD_userName"] = userName
        record["CD_isHost"]   = isHost ? 1 : 0
        record["CD_isReady"]  = 0
        record["CD_joinedAt"] = Date()
        if let imageData = profileImage {
            record["CD_userProfileImage"] = imageData as NSData
        }
        do {
            let saved = try await publicDB.save(record)
            print("✅ Participant added: \(userName)")
            return saved
        } catch {
            print("❌ addParticipant: \(error)")
            return nil
        }
    }

    func fetchParticipants(roomCode: String) async -> [CKRecord] {
        let predicate = NSPredicate(format: "CD_room == %@", roomCode)
        let query = CKQuery(recordType: "CD_RoomParticipant", predicate: predicate)
        do {
            let result = try await publicDB.records(matching: query)
            return result.matchResults.compactMap { try? $0.1.get() }
        } catch {
            print("❌ fetchParticipants: \(error)")
            return []
        }
    }

    // ─────────────────────────────────────────
    // MARK: - Photos
    // ─────────────────────────────────────────

    func uploadPhoto(roomCode: String, imageData: Data, thought: String,
                     emoji: String, userName: String, profileImage: Data?) async -> CKRecord? {
        let record = CKRecord(recordType: "CD_Photo")
        record["CD_room"]        = roomCode
        record["CD_user"]        = currentUserID
        record["CD_userName"]    = userName
        record["CD_imageData"]   = imageData as NSData
        record["CD_thought"]     = thought
        record["CD_emoji"]       = emoji
        record["CD_uploadedAt"]  = Date()
        if let profileImage {
            record["CD_userProfileImage"] = profileImage as NSData
        }
        do {
            let saved = try await publicDB.save(record)
            print("✅ Photo uploaded")
            return saved
        } catch {
            print("❌ uploadPhoto: \(error)")
            return nil
        }
    }

    func fetchPhotos(roomCode: String) async -> [CKRecord] {
        let predicate = NSPredicate(format: "CD_room == %@", roomCode)
        let query = CKQuery(recordType: "CD_Photo", predicate: predicate)
        do {
            let result = try await publicDB.records(matching: query)
            let photos = result.matchResults.compactMap { try? $0.1.get() }
            return photos.sorted {
                ($0["CD_uploadedAt"] as? Date ?? .distantPast) >
                ($1["CD_uploadedAt"] as? Date ?? .distantPast)
            }
        } catch {
            print("❌ fetchPhotos: \(error)")
            return []
        }
    }

    // ─────────────────────────────────────────
    // MARK: - Subscriptions
    // ─────────────────────────────────────────

    func subscribeToRoom(roomCode: String) {
        let predicate = NSPredicate(format: "CD_code == %@", roomCode)
        let sub = CKQuerySubscription(recordType: "CD_Room", predicate: predicate,
                                      options: [.firesOnRecordUpdate])
        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        sub.notificationInfo = info
        publicDB.save(sub) { _, error in
            if let error { print("❌ subscribeToRoom: \(error)") }
            else { print("✅ Subscribed to room updates") }
        }
    }

    func subscribeToParticipants(roomCode: String) {
        let predicate = NSPredicate(format: "CD_room == %@", roomCode)
        let sub = CKQuerySubscription(recordType: "CD_RoomParticipant", predicate: predicate,
                                      options: [.firesOnRecordCreation])
        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        sub.notificationInfo = info
        publicDB.save(sub) { _, error in
            if let error { print("❌ subscribeToParticipants: \(error)") }
            else { print("✅ Subscribed to participants") }
        }
    }

    func subscribeToPhotos(roomCode: String) {
        let predicate = NSPredicate(format: "CD_room == %@", roomCode)
        let sub = CKQuerySubscription(recordType: "CD_Photo", predicate: predicate,
                                      options: [.firesOnRecordCreation])
        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        sub.notificationInfo = info
        publicDB.save(sub) { _, error in
            if let error { print("❌ subscribeToPhotos: \(error)") }
            else { print("✅ Subscribed to photos") }
        }
    }
}
