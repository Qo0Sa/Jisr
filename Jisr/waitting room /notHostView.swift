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
    @State private var goToMain = false
    @State private var participants: [[String: Any]] = []
    @State private var missionTitle: String = ""
    @State private var missionDescription: String = ""
    @State private var roomName: String = ""
    @State private var roomCategory: String = ""
    @State private var participantsListener: ListenerRegistration? = nil
    @State private var roomListener: ListenerRegistration? = nil

    @Query private var rooms: [Room]
    @Environment(\.modelContext) private var context

    var room: Room? {
        rooms.first(where: { $0.code == roomCode })
    }

    var backgroundImageName: String {
        switch roomCategory {
        case "Cognitive": return "bluebg"
        case "Physical":  return "greenbg"
        default:          return "yellowbg"
        }
    }

    var backgroundForBtn: String {
        switch roomCategory {
        case "Cognitive": return "backbtnblue"
        case "Physical":  return "blackbtngreen"
        default:          return "back bg"
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
                        Button(action:{
                            dismiss()
                        }) {
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

                    // MISSION CARD
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            Text(missionTitle)
                                .font(.system(size: 20))
                                .foregroundColor(.black.opacity(0.75))
                            Spacer()
                            Image(systemName: "arrow.trianglehead.2.clockwise")
                                .font(.system(size: 20))
                                .foregroundColor(.black.opacity(0.75))
                        }
                        Text(missionDescription)
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.7))
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(red: 248/255, green: 242/255, blue: 230/255))
                            .cornerRadius(18)
                    }
                    .padding(16)
                    .background(Color(red: 244/255, green: 242/255, blue: 237/255))
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.7), lineWidth: 1))
                    .shadow(color: .black.opacity(0.4), radius: 0, x: 0, y: 3)
                    .padding(.horizontal, -10)
                    .offset(y: -120)

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
                                profileImageBase64: participant["profileImageBase64"] as? String
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
            if let room = room {
                CameraView(room: room, isHost: false)
            }
        }
        .navigationDestination(isPresented: $goToMain) {
            MainView()
        }
        .navigationBarHidden(true)
        .onAppear {
            // ✅ Listener للمشاركين — يتحدث فوري
            participantsListener = CloudKitManager.shared.listenToParticipants(roomCode: roomCode) { updated in
                participants = updated
            }

            // ✅ Listener للروم — يجيب المهمة والاسم والـ isStarted
            roomListener = CloudKitManager.shared.listenToRoom(roomCode: roomCode) { data in
                roomName = data["name"] as? String ?? ""
                roomCategory = data["category"] as? String ?? ""
                missionTitle = data["missionTitle"] as? String ?? ""
                missionDescription = data["missionDescription"] as? String ?? ""

                // لو الهوست ضغط Start
                if let isStarted = data["isStarted"] as? Bool, isStarted {
                    // حدّث الروم المحلي عشان CameraView يشتغل
                    if let room = rooms.first(where: { $0.code == roomCode }) {
                        room.missionTitle = missionTitle
                        room.missionDescription = missionDescription
                        room.isStarted = true
                        try? context.save()
                    }
                    goToCamera = true
                }
            }
        }
        .onDisappear {
            participantsListener?.remove()
            roomListener?.remove()
        }
    }

    struct UserCard: View {
        let name: String
        let profileImageBase64: String?

        var uiImage: UIImage? {
            guard let base64 = profileImageBase64,
                  let data = Data(base64Encoded: base64) else { return nil }
            return UIImage(data: data)
        }

        var body: some View {
            HStack(spacing: 15) {
                if let img = uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .offset(x: -10)
                } else {
                    Circle()
                        .fill(Color.black.opacity(0.08))
                        .frame(width: 50, height: 50)
                        .overlay {
                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black.opacity(0.6))
                        }
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
    }
}
