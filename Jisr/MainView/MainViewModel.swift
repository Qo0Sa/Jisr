//
//  MainViewModel.swift
//  Jisr
//
//  Created by Sarah on 25/11/1447 AH.
//
import SwiftUI
import SwiftData

@Observable
class MainViewModel {
    
    var profileImage: Image?
    var userName: String = ""
    
    // ─── جلب بيانات المستخدم ──────────────────────────
    // MainViewModel.swift
    func loadUser(context: ModelContext) {
        let descriptor = FetchDescriptor<User>()
        guard let user = try? context.fetch(descriptor).first else { return }
        
        userName = user.name
        
        // ← profileImage مو profileImageData (حسب موديلك)
        if let data = user.profileImage,
           let uiImage = UIImage(data: data) {
            profileImage = Image(uiImage: uiImage)
        }
    }
    
    // ─── إضافة روم جديد في SwiftData ─────────────────
    func addRoom(name: String, code: String, context: ModelContext) {
        let room = Room(
            name: name,
            code: code,
            category: "",
            location: "",
            maxPhotos: 100
        )
        context.insert(room)
        try? context.save()
    }
    
    // ─── توليد كود الروم ──────────────────────────────
    func generateCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        let p1 = String((0..<3).map { _ in chars.randomElement()! })
        let p2 = String((0..<3).map { _ in chars.randomElement()! })
        return "\(p1)-\(p2)"
    }
}
