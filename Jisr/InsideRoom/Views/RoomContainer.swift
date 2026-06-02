//
//  RoomContainer.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//

//
//  RoomContainer.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 01/12/1447 AH.
//

import SwiftUI
import SwiftData

struct RoomContainer: View {
    let room: Room
    let isHost: Bool
    
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
                    onSave: { thought, emoji in
                        // هنا يتم رفع الصورة الفعلية وتوثيقها ببيانات الـ SwiftData حياً مستقبلاً
                        withAnimation(.easeInOut(duration: 0.25)) {
                            capturedImage = nil
                            isShowingFeed = true // الانتقال التلقائي لمعرض الصور الحي بعد الحفظ
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
    // 1. إنشاء حاوية بيانات وهمية في الذاكرة المؤقتة للـ Preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    
    // 2. تجهيز الغرفة والمستخدم
    let sampleRoom = Room(
        name: "Mission District Mural Hunt",
        code: "JSR-777",
        category: "Creative",
        location: "Outdoor",
        maxPhotos: 9
    )
    let sampleUser = User(name: "Wteen")
    
    // إدخال البيانات في الـ Context
    container.mainContext.insert(sampleRoom)
    container.mainContext.insert(sampleUser)
    
    return NavigationStack {
        RoomContainer(room: sampleRoom, isHost: true)
            .modelContainer(container)
    }
}
