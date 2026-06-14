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
        
        let compressedImage = uiImage.compressed(maxSize: 300, quality: 0.6)
        let compressedData = compressedImage.jpegData(compressionQuality: 0.6)
        
        await MainActor.run {
            profileImage = Image(uiImage: compressedImage)
            profileImageData = compressedData
        }
    }

    func signInAnonymously() {
        if Auth.auth().currentUser != nil { return }
        Auth.auth().signInAnonymously { result, error in
            if let error { print("❌ Firebase Auth: \(error.localizedDescription)"); return }
            if let uid = result?.user.uid {
                if UserDefaults.standard.string(forKey: "iCloudUserID")?.isEmpty ?? true {
                    UserDefaults.standard.set(uid, forKey: "iCloudUserID")
                }
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

extension UIImage {
    func compressed(maxSize: CGFloat = 300, quality: CGFloat = 0.6) -> UIImage {
        let size = self.size
        let ratio = min(maxSize / size.width, maxSize / size.height)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resized ?? self
    }
}
