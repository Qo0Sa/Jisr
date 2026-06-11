//
//  JoinWithCodeSheet.swift
//  Jisr
//
//  Created by Wteen on 25/11/1447 AH.
//

import SwiftUI
import SwiftData
import CloudKit

struct JoinWithCodeSheet: View {
    @Binding var isPresented: Bool
    @State private var roomCode: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var isLoading: Bool = false      // ← أضف
    @State private var errorMessage: String = ""
    
//    var onJoined: () -> Void = {}
    
//wed
    var onJoined: (Room) -> Void = { _ in }
    @Environment(\.modelContext) private var context
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 24) {
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text("Join with code")
                        .font(.UbuntuBold(size: 22))
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0)
                }
                .padding(.top, 5)
                
                TextField("Room Code", text: $roomCode)
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(height: 54)
                    .background(Color("fieldColor")) // سحب من الـ Assets مباشرة
                    .clipShape(RoundedRectangle(cornerRadius: 99))
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .focused($isTextFieldFocused)
                
                Button(action: {
                //    isPresented = false
//                    onJoined()
                    //wed
//                    let descriptor = FetchDescriptor<Room>()

                    
//                       if let room = try? context.fetch(descriptor)
//                           .first(where: { $0.code == roomCode }) {
//                           let userDescriptor = FetchDescriptor<User>()
//                           if let currentUser = try? context.fetch(userDescriptor).first {
//                               let participant = RoomParticipant(user: currentUser, room: room)
//                               context.insert(participant)
//                               try? context.save()
//                           }
//                           
//                           
//                           onJoined(room)
//                           isPresented = false
////                       }
//                    let descriptor = FetchDescriptor<Room>(
//                        predicate: #Predicate { $0.code == roomCode }
//                    )
//
//                    guard let room = try? context.fetch(descriptor).first else {
//                        errorMessage = "❌ الكود غير صحيح"
//                        return
//                    }
//
//                    guard let currentUser = try? context.fetch(FetchDescriptor<User>()).first else {
//                        errorMessage = "لا يوجد مستخدم مسجل"
//                        return
//                    }
//
//                    // منع التكرار
//                    let alreadyJoined = room.participants?.contains {
//                        $0.user?.persistentModelID == currentUser.persistentModelID
//                    } ?? false
//
//                    if alreadyJoined {
//                        errorMessage = "أنت داخل مسبقًا"
//                        return
//                    }
//
//                    let participant = RoomParticipant(user: currentUser, room: room)
//
//                    // مهم جدًا 👇
//                    if room.participants == nil {
//                        room.participants = []
//                    }
//
//                    room.participants?.append(participant)
//                    context.insert(participant)
//
//                    try? context.save()
//
//                    onJoined(room)
//                    isPresented = false
                    Task {
                        await joinRoom()
                    }

                }) {
                    Text("Join")
                        .font(.UbuntuBold(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 170)
                        .frame(height: 58)
                        .background(
                            roomCode.isEmpty
                            ? Color("buttonColor").opacity(0.5)
                            : Color("buttonColor")
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 99))
                }
                .disabled(roomCode.isEmpty)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .padding(.horizontal, 24)
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .offset(y: isTextFieldFocused ? -60 : 0)
            .animation(.easeOut(duration: 0.25), value: isTextFieldFocused)
        }
        .onAppear {
            isTextFieldFocused = true
        }
        
        
    }
    
    
    func joinRoom() async {
        isLoading = true
        errorMessage = ""

        // ١. دور على الغرفة في CloudKit
        guard let roomRecord = await CloudKitManager.shared.fetchRoom(byCode: roomCode) else {
            errorMessage = "❌ الكود غلط، تحقق منه"
            isLoading = false
            return
        }

        // ٢. أنشئ الغرفة محلياً (مؤقتاً لحين نغير باقي الشاشات)
        let room = Room(
            name: roomRecord["CD_name"] as? String ?? "",
            code: roomCode,
            category: roomRecord["CD_category"] as? String ?? "",
            location: roomRecord["CD_location"] as? String ?? "",
            maxPhotos: roomRecord["CD_maxPhotos"] as? Int ?? 3
        )
        room.missionTitle = roomRecord["CD_missionTitle"] as? String
        room.missionDescription = roomRecord["CD_missionDescription"] as? String
        context.insert(room)
        
        // ٣. أضف الضيف كـ Participant في CloudKit
        let userDescriptor = FetchDescriptor<User>()
        if let currentUser = try? context.fetch(userDescriptor).first {
            await CloudKitManager.shared.addParticipant(
                roomCode: roomCode,
                userName: currentUser.name,
                profileImage: currentUser.profileImage,
                isHost: false
            )
        }

        // ٤. اشترك في التحديثات
        CloudKitManager.shared.subscribeToRoom(roomCode: roomCode)
        CloudKitManager.shared.subscribeToPhotos(roomCode: roomCode)

        try? context.save()
        onJoined(room)
        isPresented = false
        isLoading = false
    }
    
    
//    func joinRoom() async {
//        isLoading = true
//        errorMessage = ""
//        
////        let ckContainer = CKContainer(identifier: "iCloud.com.app.jisr")
//        let ckContainer = CKContainer.default()
//        let publicDB = ckContainer.publicCloudDatabase
//        
//        let predicate = NSPredicate(format: "CD_code == %@", roomCode)
//        let query = CKQuery(recordType: "CD_Room", predicate: predicate)
//        
//        do {
//            let result = try await publicDB.records(matching: query)
//            let records = result.matchResults.compactMap { try? $0.1.get() }
//            
//            guard let record = records.first else {
//                errorMessage = "❌ الكود غلط، تحقق منه"
//                isLoading = false
//                return
//            }
//            
//            // أنشئ الروم محلياً على جهاز شخص ٢
//            let room = Room(
//                name: record["CD_name"] as? String ?? "",
//                code: roomCode,
//                category: record["CD_category"] as? String ?? "",
//                location: record["CD_location"] as? String ?? "",
//                maxPhotos: record["CD_maxPhotos"] as? Int ?? 3
//            )
//            context.insert(room)
//            
//            let userDescriptor = FetchDescriptor<User>()
//            if let currentUser = try? context.fetch(userDescriptor).first {
//                let participant = RoomParticipant(user: currentUser, room: room)
//                context.insert(participant)
//            }
//            
//            try? context.save()
//            onJoined(room)
//            isPresented = false
//            
//        } catch {
//            errorMessage = "تأكد من الإنترنت وحاول مرة ثانية"
//            print("❌ CloudKit error: \(error)")
//        }
//        
//        isLoading = false
//    }

}

#Preview {
    JoinWithCodeSheet(isPresented: .constant(true))
}
