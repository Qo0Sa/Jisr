//
//  UserViewModel.swift
//  Jisr
//

import SwiftUI
import PhotosUI
import SwiftData
import FirebaseAuth

@Observable
class UserViewModel {
    var name = ""
    var selectedPhoto: PhotosPickerItem?
    var profileImage: Image?
    var profileImageData: Data?

    var isValid: Bool { !name.isEmpty }

    func loadImage() async {
        guard let item = selectedPhoto else { return }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }
        await MainActor.run {
            profileImage = Image(uiImage: uiImage)
            profileImageData = data
        }
    }

    func signInAnonymously() {
        if Auth.auth().currentUser != nil { return }
        Auth.auth().signInAnonymously { result, error in
            if let error { print("❌ Firebase Auth: \(error.localizedDescription)"); return }
            if let uid = result?.user.uid {
                UserDefaults.standard.set(uid, forKey: "iCloudUserID")
                print("✅ Firebase UID: \(uid)")
            }
        }
    }

    func saveUser(context: ModelContext) {
        let user = User(name: name, profileImage: profileImageData)
        context.insert(user)
        do {
            try context.save()
            print("✅ User saved: \(user.name)")
        } catch {
            print("❌ Failed to save: \(error.localizedDescription)")
        }
    }
}
