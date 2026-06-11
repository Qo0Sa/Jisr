//
//  CloudKitManager.swift
//  Jisr
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class CloudKitManager {

    static let shared = CloudKitManager()
    private let db = Firestore.firestore()

    var currentUserID: String {
        Auth.auth().currentUser?.uid ?? UserDefaults.standard.string(forKey: "iCloudUserID") ?? ""
    }

    // ─────────────────────────────────────────
    // MARK: - Room
    // ─────────────────────────────────────────

    func createRoom(name: String, code: String, category: String,
                    location: String, maxPhotos: Int,
                    missionTitle: String, missionDescription: String) async -> [String: Any]? {
        let data: [String: Any] = [
            "name": name,
            "code": code,
            "category": category,
            "location": location,
            "maxPhotos": maxPhotos,
            "isStarted": false,
            "isClosed": false,
            "missionTitle": missionTitle,
            "missionDescription": missionDescription,
            "hostUserID": currentUserID,
            "createdAt": Timestamp()
        ]
        do {
            try await db.collection("rooms").document(code).setData(data)
            print("✅ Room created: \(code)")
            return data
        } catch {
            print("❌ createRoom: \(error)")
            return nil
        }
    }

    func fetchRoom(byCode code: String) async -> [String: Any]? {
        do {
            let doc = try await db.collection("rooms").document(code).getDocument()
            return doc.data()
        } catch {
            print("❌ fetchRoom: \(error)")
            return nil
        }
    }

    func updateRoom(roomCode: String, isStarted: Bool? = nil, isClosed: Bool? = nil) async {
        var updates: [String: Any] = [:]
        if let isStarted { updates["isStarted"] = isStarted }
        if let isClosed  { updates["isClosed"]  = isClosed  }
        guard !updates.isEmpty else { return }
        do {
            try await db.collection("rooms").document(roomCode).updateData(updates)
            print("✅ Room updated")
        } catch {
            print("❌ updateRoom: \(error)")
        }
    }

    // ─────────────────────────────────────────
    // MARK: - Participants
    // ─────────────────────────────────────────

    func addParticipant(roomCode: String, userName: String,
                        profileImage: Data?, isHost: Bool) async {
        var data: [String: Any] = [
            "roomCode": roomCode,
            "userID": currentUserID,
            "userName": userName,
            "isHost": isHost,
            "isReady": false,
            "joinedAt": Timestamp()
        ]
        if let imageData = profileImage {
            data["profileImageBase64"] = imageData.base64EncodedString()
        }
        do {
            let docID = "\(roomCode)_\(currentUserID)"
            try await db.collection("participants").document(docID).setData(data)
            print("✅ Participant added: \(userName)")
        } catch {
            print("❌ addParticipant: \(error)")
        }
    }

    func fetchParticipants(roomCode: String) async -> [[String: Any]] {
        do {
            let snapshot = try await db.collection("participants")
                .whereField("roomCode", isEqualTo: roomCode)
                .getDocuments()
            return snapshot.documents.map { $0.data() }
        } catch {
            print("❌ fetchParticipants: \(error)")
            return []
        }
    }

    // ─────────────────────────────────────────
    // MARK: - Photos
    // ─────────────────────────────────────────

    func uploadPhoto(roomCode: String, imageData: Data, thought: String,
                     emoji: String, userName: String, profileImage: Data?) async {
        var data: [String: Any] = [
            "roomCode": roomCode,
            "userID": currentUserID,
            "userName": userName,
            "imageBase64": imageData.base64EncodedString(),
            "thought": thought,
            "emoji": emoji,
            "uploadedAt": Timestamp()
        ]
        if let profileImage {
            data["profileImageBase64"] = profileImage.base64EncodedString()
        }
        do {
            try await db.collection("photos").addDocument(data: data)
            print("✅ Photo uploaded")
        } catch {
            print("❌ uploadPhoto: \(error)")
        }
    }

    func fetchPhotos(roomCode: String) async -> [[String: Any]] {
        do {
            let snapshot = try await db.collection("photos")
                .whereField("roomCode", isEqualTo: roomCode)
                .order(by: "uploadedAt", descending: true)
                .getDocuments()
            return snapshot.documents.map { $0.data() }
        } catch {
            print("❌ fetchPhotos: \(error)")
            return []
        }
    }

    // ─────────────────────────────────────────
    // MARK: - Realtime Listeners ✅ مصلحة
    // ─────────────────────────────────────────

    func listenToRoom(roomCode: String, onChange: @escaping ([String: Any]) -> Void) -> ListenerRegistration {
        return db.collection("rooms").document(roomCode)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ listenToRoom: \(error)")
                    return
                }
                if let data = snapshot?.data() {
                    DispatchQueue.main.async { onChange(data) }
                }
            }
    }

    func listenToParticipants(roomCode: String, onChange: @escaping ([[String: Any]]) -> Void) -> ListenerRegistration {
        return db.collection("participants")
            .whereField("roomCode", isEqualTo: roomCode)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ listenToParticipants: \(error)")
                    return
                }
                let participants = snapshot?.documents.map { $0.data() } ?? []
                DispatchQueue.main.async { onChange(participants) }
            }
    }

    // للتوافق مع الكود القديم
    func subscribeToRoom(roomCode: String) {}
    func subscribeToParticipants(roomCode: String) {}
    func subscribeToPhotos(roomCode: String) {}
}
