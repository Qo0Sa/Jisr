//
//  UserViewModel.swift
//  Jisr
//
//  Created by Sarah on 24/11/1447 AH.
//

import SwiftUI
import PhotosUI
import SwiftData
import CloudKit
@Observable
class UserViewModel {
    var name = ""
    var selectedPhoto: PhotosPickerItem?
    var profileImage: Image?
    var profileImageData: Data?
    
    var isValid: Bool {
        !name.isEmpty
    }
    
    func loadImage() async {
        guard let item = selectedPhoto else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            profileImage = Image(uiImage: uiImage)
            profileImageData = data
        }
    }
    
    func fetchAndSaveiCloudID() {
        CKContainer.default().fetchUserRecordID { recordID, error in
            guard let id = recordID?.recordName else { return }
            UserDefaults.standard.set(id, forKey: "iCloudUserID")
            print("✅ iCloud ID saved: \(id)")
        }
    }
    
    
//    func saveUser(context: ModelContext) {
//        let user = User(name: name, profileImage: profileImageData)
//        context.insert(user)
//    }
    func saveUser(context: ModelContext) {
        let user = User(name: name, profileImage: profileImageData)
        context.insert(user)
        do {
                    try context.save()
                    print("✅ User saved and context synced: \(user.name)")
                } catch {
                    print("❌ Failed to save context: \(error.localizedDescription)")
                }
    }
    
    
    
    
    
}
