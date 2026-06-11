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

    @State private var isShowingEndPopup = false
    @State private var isRoomFinished = false
    @State private var photos: [[String: Any]] = []
    @State private var photosListener: ListenerRegistration? = nil

    let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                RoomHeader(
                    room: room,
                    currentProgress: photos.count,
                    maxPhotos: room.maxPhotos,
                    isShowingFeed: isShowingFeed,
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
                                let imageData: Data? = {
                                    guard let base64 = photo["imageBase64"] as? String else { return nil }
                                    return Data(base64Encoded: base64)
                                }()
                                let profileData: Data? = {
                                    guard let base64 = photo["profileImageBase64"] as? String else { return nil }
                                    return Data(base64Encoded: base64)
                                }()
                                FeedCard(
                                    userName: photo["userName"] as? String ?? "Member",
                                    userImageData: profileData,
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
                        withAnimation(.easeInOut(duration: 0.2)) { isShowingEndPopup = true }
                    }) {
                        Text("End Room")
                            .font(.UbuntuBold(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 58)
                            .background(Color(red: 0.18, green: 0.18, blue: 0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                }
            }

            if isShowingEndPopup {
                EndRoomPopup(
                    isPresented: $isShowingEndPopup,
                    onConfirmEnd: {
                        Task {
                            await CloudKitManager.shared.updateRoom(roomCode: room.code, isClosed: true)
                        }
                        room.isClosed = true
                        try? context.save()
                        isRoomFinished = true
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
        .onAppear {
            // ✅ Realtime listener بدل Timer
            photosListener = Firestore.firestore()
                .collection("photos")
                .whereField("roomCode", isEqualTo: room.code)
                .order(by: "uploadedAt", descending: true)
                .addSnapshotListener { snapshot, _ in
                    photos = snapshot?.documents.map { $0.data() } ?? []
                }
        }
        .onDisappear {
            photosListener?.remove()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    let sampleRoom = Room(name: "Mission District Mural Hunt", code: "JSR-659", category: "Creative", location: "Outdoor", maxPhotos: 9)
    container.mainContext.insert(sampleRoom)
    return RoomFeed(room: sampleRoom, isHost: true, isShowingFeed: .constant(true))
        .modelContainer(container)
}
