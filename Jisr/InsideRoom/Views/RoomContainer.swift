//
//  RoomContainer.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//
//  ⚠️ DISABLED — replaced by CameraView in InsideRoom/sara/Cameraview.swift
//

#if false

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
                PhotoReview(
                    capturedImage: uiImage,
                    onCancel: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            capturedImage = nil
                        }
                    },
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
                            emoji: emoji,
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
                RoomFeed(room: room, isHost: isHost, isShowingFeed: $isShowingFeed)
            } else {
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
        .toolbarBackground(.hidden, for: .navigationBar)
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

#endif
