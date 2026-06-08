//
//  RoomContainer.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//

import SwiftUI
import SwiftData

struct RoomContainer: View {
    let room: Room
    let isHost: Bool
    
    // 💡 جلب الـ context وقائمة اليوزرز لربط لقطة الصورة باليوزر المسجل حياً
    @Environment(\.modelContext) private var context
    @Query private var users: [User]
    
    @State private var isShowingFeed = false
    @State private var capturedImage: UIImage? = nil
    
    var body: some View {
        Group {
            if let uiImage = capturedImage {
                // إذا التقط المستخدم صورة، نوجهه تلقائياً لشاشة المراجعة وكتابة التفكير اللحظي
                PhotoReview(
                    capturedImage: uiImage,
                    onCancel: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            capturedImage = nil // مسح اللقطة والعودة الفورية للكاميرا
                        }
                    },
//                    onSave: { thought, emoji in
//
//                        if let photoData = uiImage.jpegData(compressionQuality: 0.8) {
//                            
//                            if let currentUser = users.first {
//                                
//                                let newPhoto = Photo(
//                                    imageData: photoData,
//                                    thought: thought,
//                                    room: room,
//                                    user: currentUser
//                                )
//                                context.insert(newPhoto)
//                                try? context.save() // إجبار المزامنة الفورية على نطاق التطبيق لضمان ظهورها في الهستوري والمعرض
//                            }
//                        }
//                        
//                        withAnimation(.easeInOut(duration: 0.25)) {
//                            capturedImage = nil
//                            isShowingFeed = true // الانتقال التلقائي لمعرض الصور الحي بعد الحفظ
//                        }
//                    }
                    
                    onSave: { thought, emoji in

                        guard let uiImage = capturedImage,
                              let imageData = uiImage.jpegData(compressionQuality: 0.8) else {
                            return
                        }

                        guard let currentUser = users.first else {
                            print("No user found")
                            return
                        }


                        let newPhoto = Photo(
                            imageData: imageData,
                            thought: thought,
                            room: room,
                            user: currentUser
                        )
                        

                        context.insert(newPhoto)

                        do {
                            try context.save()
                        } catch {
                            print("Save failed: \(error)")
                        }

                        withAnimation(.easeInOut(duration: 0.25)) {
                            capturedImage = nil
                            isShowingFeed = true
                        }
                    }
                )
            } else if isShowingFeed {
                // شاشة المعرض الحي المشترك للروم
                RoomFeed(room: room, isHost: isHost, isShowingFeed: $isShowingFeed)
            } else {
                // شاشة عدسة الكاميرا الافتراضية للروم
                RoomCamera(
                    room: room,
                    isShowingFeed: $isShowingFeed,
                    onPhotoCaptured: { image in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            capturedImage = image
                        }
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    
    let sampleRoom = Room(
        name: "Mission District Mural Hunt",
        code: "JSR-777",
        category: "Creative",
        location: "Outdoor",
        maxPhotos: 9
    )
    let sampleUser = User(name: "Wteen")
    
    container.mainContext.insert(sampleRoom)
    container.mainContext.insert(sampleUser)
    
    return NavigationStack {
        RoomContainer(room: sampleRoom, isHost: true)
            .modelContainer(container)
    }
}
