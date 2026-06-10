//
//  RoomFeed.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//

import SwiftUI
import SwiftData
import CloudKit

struct RoomFeed: View {
    @Environment(\.modelContext) private var context
    
    let room: Room
    let isHost: Bool
    @Binding var isShowingFeed: Bool
    
    @State private var isShowingEndPopup = false
    @State private var isRoomFinished = false
    
    @State private var ckPhotos: [CKRecord] = []
    @State private var roomRecordID: CKRecord.ID? = nil
    @State private var refreshTimer: Timer? = nil
    
    var roomPhotos: [CKRecord] { ckPhotos }
    
    let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    
    
    func loadPhotos() {
        Task {
            ckPhotos = await CloudKitManager.shared.fetchPhotos(roomCode: room.code)
        }
    }
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                RoomHeader(
                    room: room,
                    currentProgress: roomPhotos.count,
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
                    if roomPhotos.isEmpty {
                        VStack(spacing: 12) {
                            Spacer().frame(height: 120)
                            Image(systemName: "photo.on.rectangle.angled").font(.system(size: 48)).foregroundColor(.black.opacity(0.12))
                            Text("No photos captured yet").font(.UbuntuBold(size: 16)).foregroundColor(.black.opacity(0.4))
                        }
                        .padding(.horizontal, 40)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(ckPhotos, id: \.recordID) { photo in
                                let thought = photo["CD_thought"] as? String ?? ""
                                FeedCard(
                                    userName: photo["CD_userName"] as? String ?? "Member",
                                    userImageData: photo["CD_userProfileImage"] as? Data,
                                    thoughtText: thought.isEmpty ? "Capturing the moment!" : thought,
                                    emojiReaction: photo["CD_emoji"] as? String ?? "😊",
                                    imageData: photo["CD_imageData"] as? Data
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            
            // 💡 حصر صلاحية زر إنهاء الروم السفلي للهوست فقط، وضبط توسيط الأبعاد (width: 200) لفيجما
            if isHost {
                VStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) { isShowingEndPopup = true }
                    }) {
                        Text("End Room")
                            .font(.UbuntuBold(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 58) // الأبعاد الملمومة المتمركزة بالسنتر بدقة
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
                            guard let recordID = roomRecordID else { return }
                            await CloudKitManager.shared.updateRoom(recordID: recordID, isClosed: 1)
                        }
                        room.isClosed = true
                        try? context.save()
                        isRoomFinished = true                    }
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
            loadPhotos()
            Task {
                if let record = await CloudKitManager.shared.fetchRoom(byCode: room.code) {
                    roomRecordID = record.recordID
                }
            }
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                loadPhotos()
            }
        }
        .onDisappear {
            refreshTimer?.invalidate()
        }
        
        .onReceive(NotificationCenter.default.publisher(for: .cloudKitDataChanged)) { _ in
            loadPhotos()
        }
        
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    let sampleRoom = Room(name: "Mission District Mural Hunt", code: "JSR-659", category: "Creative", location: "Outdoor", maxPhotos: 9)
    let sampleUser = User(name: "Wteen Alghamdy")
    container.mainContext.insert(sampleRoom)
    container.mainContext.insert(sampleUser)
    
    return RoomFeed(room: sampleRoom, isHost: true, isShowingFeed: .constant(true))
        .modelContainer(container)
}
