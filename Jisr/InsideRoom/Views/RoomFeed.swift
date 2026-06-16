//
//  RoomFeed.swift
//  Jisr
//

import SwiftUI
import SwiftData
import FirebaseFirestore

struct RoomFeed: View {
    @Environment(\.modelContext) private var context

    let room: Room
    let isHost: Bool
    @Binding var isShowingFeed: Bool
    let photos: [[String: Any]]   // ✅ يجي من CameraView
    let participants: [[String: Any]]

    @State private var isShowingEndPopup = false
    @State private var isRoomFinished = false
    @State private var isEndingRoom = false

    let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    private var totalRequiredPhotos: Int {
        participants.count * room.maxPhotos
    }
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                RoomHeader(
                    room: room,
                    currentProgress: photos.count,
                    maxPhotos: totalRequiredPhotos,
                    isShowingFeed: isShowingFeed,
                    participants: participants,
                    photos: photos,
                    onGalleryToggle: nil,
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isShowingFeed = false
                        }
                    }
                )
                .padding(.vertical, 12)

                ScrollView(.vertical, showsIndicators: false) {
                    if photos.isEmpty {
                        VStack(spacing: 12) {
                            Spacer().frame(height: 120)
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 48))
                                .foregroundColor(.black.opacity(0.12))
                            Text("No photos captured yet")
                                .font(.UbuntuBold(size: 16))
                                .foregroundColor(.black.opacity(0.4))
                        }
                        .padding(.horizontal, 40)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Array(photos.enumerated()), id: \.offset) { _, photo in

                                let thought = photo["thought"] as? String ?? ""

                                let imageData = photo["imageData"] as? Data

//                                let profileData = photo["profileImageData"] as? Data
                                let profileImage = decodeProfileImage(photo["profileImageData"])

                                FeedCard(
                                    userName: photo["userName"] as? String ?? "Member",
                                    userImage: profileImage,
                                    thoughtText: thought.isEmpty ? "Capturing the moment!" : thought,
                                    emojiReaction: photo["emoji"] as? String ?? "😊",
                                    imageData: imageData
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }

            if isHost {
                VStack {
                    Spacer()
                    Button(action: {
                        guard !isEndingRoom else { return }
                        withAnimation(.easeInOut(duration: 0.2)) { isShowingEndPopup = true }
                    }) {
                        Group {
                            if isEndingRoom {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("End Room")
                                    .font(.UbuntuBold(size: 20))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 200, height: 58)
                        .background(Color(red: 0.18, green: 0.18, blue: 0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 99))
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                    }
                    .disabled(isEndingRoom)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                }
            }

            if isShowingEndPopup {
                EndRoomPopup(
                    isPresented: $isShowingEndPopup,
                    onConfirmEnd: {
                        guard !isEndingRoom else { return }
                        isEndingRoom = true
                        Task {
                            let didClose = await CloudKitManager.shared.updateRoom(roomCode: room.code, isClosed: true)
                            await MainActor.run {
                                isEndingRoom = false
                                guard didClose else { return }
                                room.isClosed = true
                                try? context.save()
                                isRoomFinished = true
                            }
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .background(Color("Backgroundcolor").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isRoomFinished) {
            RoomSummary(room: room)
        }
    }
    func decodeProfileImage(_ value: Any?) -> UIImage? {
        if let data = value as? Data {
            return UIImage(data: data)
        }

        if let base64 = value as? String,
           let data = Data(base64Encoded: base64) {
            return UIImage(data: data)
        }

        return nil
    }
}

//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
//    let sampleRoom = Room(name: "Mission District Mural Hunt", code: "JSR-659", category: "Creative", location: "Outdoor", maxPhotos: 9)
//    container.mainContext.insert(sampleRoom)
//    RoomFeed(room: sampleRoom, isHost: true, isShowingFeed: .constant(true), photos: [])
//        .modelContainer(container)
//}
