//
//  UserViewModel.swift
//  Jisr
//
//  Created by Sarah on 24/11/1447 AH.
//

import SwiftUI
import PhotosUI
import SwiftData

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
    
    func saveUser(context: ModelContext) {
        let user = User(name: name, profileImage: profileImageData)
        context.insert(user)
    }
}
