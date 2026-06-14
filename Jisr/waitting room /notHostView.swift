//
//  notHostView.swift
//  Jisr
//

import SwiftUI
import SwiftData
import FirebaseFirestore

struct WaitingRoomForNotHostView: View {
    
    let roomCode: String
    @Environment(\.dismiss) private var dismiss
    @State private var goToCamera = false
    @State private var participants: [[String: Any]] = []
    @State private var missionTitle: String = ""
    @State private var missionDescription: String = ""
    @State private var roomName: String = ""
    @State private var roomCategory: String = ""
    @State private var roomLocation: String = ""
    @State private var roomMaxPhotos: Int = 3
    @State private var participantsListener: ListenerRegistration? = nil
    @State private var roomListener: ListenerRegistration? = nil
    
    // ✅ الروم يتبنى في الـ memory — ما نحتاج SwiftData
    @State private var localRoom: Room? = nil
    
    @Environment(\.modelContext) private var context
    
    var backgroundImageName: String {
        switch roomCategory {
        case "Cognitive": return "bluebg"
        case "Physical":  return "greenbg"
        default:          return "yellowbg"
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                VStack {
                    
                    // HEADER
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Text(roomName)
                            .font(.UbuntuBold(size: 22))
                        Spacer()
                        Color.clear.frame(width: 24)
                    }
                    .offset(y: -30)
                    
                    // MISSION CARD — بدون زر التغيير للـ not host
                    VStack(alignment: .leading, spacing: 12) {

                        HStack(alignment: .top) {
                            Text(missionTitle)
                                .font(.system(size: 20))
                                .foregroundColor(.black.opacity(0.75))


                        }

                        Text(missionDescription)
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.7))
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(red: 248/255, green: 242/255, blue: 230/255)) // F8F2E6
                            .cornerRadius(18)
                    }
                    .padding(16)
                    .background(Color(red: 252/255, green: 250/255, blue: 245/255)) // FCFAF5
                    .cornerRadius(24)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 24)
//                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
//                    )
                    .shadow(color: Color.black.opacity(0.9), radius: 0, x: 0, y: 6) // نفس ستايل الكود
                    .padding(.horizontal, -10)
                    .offset(y: -110)
                    
                    
                    
                    
                    
                    // PARTICIPANTS COUNT
                    HStack {
                        Label("\(participants.count)", systemImage: "person.fill")
                    }
                    .offset(y: -100)
                }
                .padding(.horizontal, 25)
                
                // LIST
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        ForEach(Array(participants.enumerated()), id: \.offset) { _, participant in
                            UserCard(
                                name: participant["userName"] as? String ?? "Unknown",
                                profileImageData: participant["profileImageData"] as? Data
                            )
                        }
                        Color.clear.frame(height: 30)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 40)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .offset(y: -90)
            }
        }
        .navigationDestination(isPresented: $goToCamera) {
            if let room = localRoom {
                CameraView(room: room, isHost: false)
            } else {
                Text("جاري التحميل...")
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            let descriptor = FetchDescriptor<Room>()
            if let savedRooms = try? context.fetch(descriptor),
               let existingRoom = savedRooms.first(where: { $0.code == roomCode }) {
                localRoom = existingRoom
            }
            
            // ✅ Listener للمشاركين
            participantsListener = CloudKitManager.shared.listenToParticipants(roomCode: roomCode) { updated in
                print("🎯 HOST UI UPDATED")
                print("🎯 participants count = \(updated.count)")
                participants = updated
            }
            
            roomListener = CloudKitManager.shared.listenToRoom(roomCode: roomCode) { data in
                print("📡 room data وصل: \(data)")
                print("🎯 isStarted: \(data["isStarted"] ?? "nil")")
                print("📝 missionTitle: \(data["missionTitle"] ?? "nil")")
                
                roomName     = data["name"]     as? String ?? ""
                roomCategory = data["category"] as? String ?? ""
                roomLocation = data["location"] as? String ?? ""
                roomMaxPhotos = data["maxPhotos"] as? Int ?? 3
                
                let title = data["missionTitle"] as? String ?? ""
                let desc  = data["missionDescription"] as? String ?? ""
                if !title.isEmpty { missionTitle = title }
                if !desc.isEmpty  { missionDescription = desc }
                
                // ✅ لو الهوست ضغط Start
                if let isStarted = data["isStarted"] as? Bool, isStarted {
                    
                    if let existingRoom = localRoom {
                        existingRoom.name = roomName
                        existingRoom.category = roomCategory
                        existingRoom.location = roomLocation
                        existingRoom.maxPhotos = roomMaxPhotos
                        existingRoom.missionTitle = missionTitle
                        existingRoom.missionDescription = missionDescription
                        existingRoom.isStarted = true
                    } else {
                        let newRoom = Room(
                            name: roomName,
                            code: roomCode,
                            category: roomCategory,
                            location: roomLocation,
                            maxPhotos: roomMaxPhotos
                        )
                        newRoom.missionTitle = missionTitle
                        newRoom.missionDescription = missionDescription
                        newRoom.isStarted = true
                        context.insert(newRoom)
                        try? context.save()
                        localRoom = newRoom
                    }
                    try? context.save()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        goToCamera = true
                    }
                }
            }
        }
        
        .onDisappear {
            participantsListener?.remove()
            roomListener?.remove()
        }
    }
    
    //    struct UserCard: View {
    //        let name: String
    //        let profileImageBase64: String?
    //
    //        var uiImage: UIImage? {
    //            guard let base64 = profileImageBase64,
    //                  let data = Data(base64Encoded: base64) else { return nil }
    //            return UIImage(data: data)
    //        }
    //
    //        var body: some View {
    //            HStack(spacing: 15) {
    //                if let img = uiImage {
    //                    Image(uiImage: img)
    //                        .resizable()
    //                        .scaledToFill()
    //                        .frame(width: 50, height: 50)
    //                        .clipShape(Circle())
    //                        .offset(x: -10)
    //                } else {
    //                    Circle()
    //                        .fill(Color.black.opacity(0.08))
    //                        .frame(width: 50, height: 50)
    //                        .overlay {
    //                            Text(String(name.prefix(1)).uppercased())
    //                                .font(.system(size: 20, weight: .bold))
    //                                .foregroundColor(.black.opacity(0.6))
    //                        }
    //                }
    //                Spacer()
    //                Text(name)
    //                    .font(.UbuntuBold(size: 18))
    //                    .foregroundColor(.black.opacity(0.8))
    //                    .padding(.trailing, 60)
    //            }
    //            .padding(.horizontal, 18)
    //            .padding(.vertical, 6)
    //            .background(Color.white.opacity(0.6))
    //            .cornerRadius(45)
    //            .fixedSize()
    //        }
    //    }
    struct UserCard: View {
        let name: String
        let profileImageData: Data?

        var uiImage: UIImage? {
            guard let data = profileImageData else { return nil }
            return UIImage(data: data)
        }

        var body: some View {
            HStack(spacing: 15) {

                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .offset(x: -10) // نفس التأثير من الكود الأول
                } else {
                    fallback
                        .offset(x: -10) // مهم عشان نفس الشكل
                }

                Spacer()

                Text(name)
                    .font(.UbuntuBold(size: 18))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.trailing, 60)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.6))
            .cornerRadius(45)
            .fixedSize()
        }

        var fallback: some View {
            Circle()
                .fill(Color.black.opacity(0.08))
                .frame(width: 50, height: 50)
                .overlay {
                    Text(String(name.prefix(1)).uppercased())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black.opacity(0.6))
                }
        }
    }
}
