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
        let defaults = UserDefaults.standard

        if let firebaseID = Auth.auth().currentUser?.uid, !firebaseID.isEmpty {
            defaults.set(firebaseID, forKey: "iCloudUserID")
            return firebaseID
        }

        if let savedID = defaults.string(forKey: "iCloudUserID"), !savedID.isEmpty {
            return savedID
        }

        let fallbackID = "local-\(UUID().uuidString)"
        defaults.set(fallbackID, forKey: "iCloudUserID")
        return fallbackID
    }

    private func authenticatedUserID() async -> String {
        let defaults = UserDefaults.standard

        if let firebaseID = Auth.auth().currentUser?.uid, !firebaseID.isEmpty {
            defaults.set(firebaseID, forKey: "iCloudUserID")
            return firebaseID
        }

        do {
            let result: AuthDataResult = try await withCheckedThrowingContinuation { continuation in
                Auth.auth().signInAnonymously { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let result {
                        continuation.resume(returning: result)
                    } else {
                        continuation.resume(throwing: NSError(domain: "FirebaseAuth", code: -1, userInfo: nil))
                    }
                }
            }
            let uid = result.user.uid
            defaults.set(uid, forKey: "iCloudUserID")
            return uid
        } catch {
            print("❌ Firebase Auth: \(error.localizedDescription)")
            return currentUserID
        }
    }

    private func sortedParticipants(_ participants: [[String: Any]]) -> [[String: Any]] {
        participants.sorted { first, second in
            let firstIsHost = first["isHost"] as? Bool ?? false
            let secondIsHost = second["isHost"] as? Bool ?? false

            if firstIsHost != secondIsHost {
                return firstIsHost
            }

            let firstJoined = (first["joinedAt"] as? Timestamp)?.dateValue() ?? .distantPast
            let secondJoined = (second["joinedAt"] as? Timestamp)?.dateValue() ?? .distantPast
            return firstJoined < secondJoined
        }
    }

    // ─────────────────────────────────────────
    // MARK: - Room
    // ─────────────────────────────────────────

    func createRoom(name: String, code: String, category: String,
                    location: String, maxPhotos: Int,
                    missionTitle: String, missionDescription: String) async -> [String: Any]? {
        let userID = await authenticatedUserID()
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
            "hostUserID": userID,
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

    @discardableResult
    func updateRoom(roomCode: String, isStarted: Bool? = nil, isClosed: Bool? = nil,
                    missionTitle: String? = nil, missionDescription: String? = nil) async -> Bool {
        var updates: [String: Any] = [:]
        if let isStarted          { updates["isStarted"]           = isStarted          }
        if let isClosed           { updates["isClosed"]            = isClosed           }
        if let missionTitle       { updates["missionTitle"]        = missionTitle       }
        if let missionDescription { updates["missionDescription"]  = missionDescription }
        guard !updates.isEmpty else { return true }
        do {
            try await db.collection("rooms")
                .document(roomCode)
                .updateData(updates)
            return true
        } catch {
            print("❌ updateRoom: \(error)")
            return false
        }
    }
    // ─────────────────────────────────────────
    // MARK: - Participants
    // ─────────────────────────────────────────

//    func addParticipant(roomCode: String, userName: String,
//                        profileImage: Data?, isHost: Bool) async {
//        let userID = await authenticatedUserID()
//        var profileURL: String? = nil
//
//        if let imageData = profileImage {
//            profileURL = try? await uploadProfileImage(imageData)
//        }
//
//        var data: [String: Any] = [
//            "roomCode": roomCode,
//            "userID": userID,
//            "userName": userName,
//            "isHost": isHost,
//            "isReady": false,
//            "joinedAt": Timestamp(),
////            "profileImageURL": profileURL as Any
//        ]
//        if let profileURL {
//            data["profileImageURL"] = profileURL
//        }
//        if let imageData = profileImage {
//            data["profileImageBase64"] = imageData.base64EncodedString()
//        }
//        do {
//            let docID = "\(roomCode)_\(userID)"
//            try await db.collection("participants").document(docID).setData(data)
//            print("✅ Participant added: \(userName)")
//        } catch {
//            print("❌ addParticipant: \(error)")
//        }
//    }

    func addParticipant(
        roomCode: String,
        userName: String,
        profileImage: Data?,
        isHost: Bool
    ) async {

        let userID = await authenticatedUserID()

        var data: [String: Any] = [
            "roomCode": roomCode,
            "userID": userID,
            "userName": userName,
            "isHost": isHost,
            "isReady": false,
            "joinedAt": Timestamp()
        ]

        // ضغط الصورة قبل حفظها
        if let imageData = profileImage,
           let uiImage = UIImage(data: imageData),
           let compressedData = uiImage.jpegData(compressionQuality: 0.2) {

            print("📸 Original Size = \(imageData.count)")
            print("📸 Compressed Size = \(compressedData.count)")

            data["profileImageData"] = compressedData
        }

        do {
            let docID = "\(roomCode)_\(userID)"

            try await db.collection("participants")
                .document(docID)
                .setData(data)

            print("✅ SAVED SUCCESSFULLY")

        } catch {
            print("❌ SAVE FAILED")
            print(error.localizedDescription)
        }
    }
    
    
    
    func fetchParticipants(roomCode: String) async -> [[String: Any]] {
        do {
            let snapshot = try await db.collection("participants")
                .whereField("roomCode", isEqualTo: roomCode)
                .getDocuments()
            return sortedParticipants(snapshot.documents.map { $0.data() })
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
        let userID = await authenticatedUserID()
        var data: [String: Any] = [
            "roomCode": roomCode,
            "userID": userID,
            "userName": userName,
            "imageData": imageData,
            "thought": thought,
            "emoji": emoji,
            "uploadedAt": Timestamp()
        ]
        if let profileImage {
            data["profileImageData"] = profileImage.base64EncodedString()
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
                let participants = self.sortedParticipants(snapshot?.documents.map { $0.data() } ?? [])
                DispatchQueue.main.async { onChange(participants) }
            }
    }

    func uploadProfileImage(_ imageData: Data) async -> String? {
        print(Storage.storage().reference().bucket)
        let userID = await authenticatedUserID()

        let ref = Storage.storage()
            .reference()
            .child("profileImages/\(userID).jpg")

        do {
            _ = try await ref.putDataAsync(imageData)

            let url = try await ref.downloadURL()

            return url.absoluteString
            

        } catch {
            print("❌ Upload image error: \(error)")
            return nil
        }
        
        
        
    }    // للتوافق مع الكود القديم
    func subscribeToRoom(roomCode: String) {}
    func subscribeToParticipants(roomCode: String) {}
    func subscribeToPhotos(roomCode: String) {}
}
