//
//  notHostView.swift
//  Jisr
//

import SwiftUI
import SwiftData
import FirebaseFirestore

struct WaitingRoomForNotHostView: View {

    let roomCode: String

    @State private var goToCamera = false
    @State private var goToMain = false
    @State private var participants: [[String: Any]] = []
    @State private var participantsListener: ListenerRegistration? = nil
    @State private var roomListener: ListenerRegistration? = nil

    @Query private var rooms: [Room]

    var room: Room? {
        rooms.first(where: { $0.code == roomCode })
    }

    var backgroundImageName: String {
        switch room?.category {
        case "Cognitive": return "bluebg"
        case "Physical":  return "greenbg"
        default:          return "yellowbg"
        }
    }

    var body: some View {
        Group {
            if let room = room {
                ZStack(alignment: .bottom) {

                    Image(backgroundImageName)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    VStack {
                        VStack {

                            HStack {
                                Button(action: { goToMain = true }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                Spacer()
                                Text(room.name)
                                    .font(.UbuntuBold(size: 22))
                                Spacer()
                                Color.clear.frame(width: 24)
                            }
                            .offset(y: -30)

                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .top) {
                                    Text(room.missionTitle ?? "")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.black.opacity(0.75))
                                    Spacer()
                                    Image(systemName: "arrow.trianglehead.2.clockwise")
                                        .font(.system(size: 20))
                                        .foregroundColor(.black.opacity(0.75))
                                }
                                Text(room.missionDescription ?? "")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black.opacity(0.7))
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(red: 233/255, green: 227/255, blue: 214/255))
                                    .cornerRadius(18)
                            }
                            .padding(16)
                            .background(Color(red: 244/255, green: 242/255, blue: 237/255))
                            .cornerRadius(24)
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.7), lineWidth: 1))
                            .shadow(color: .black.opacity(0.4), radius: 0, x: 0, y: 3)
                            .padding(.horizontal, -10)
                            .offset(y: -120)

                            HStack {
                                Label("\(participants.count)", systemImage: "person.fill")
                            }
                            .offset(y: -100)
                        }
                        .padding(.horizontal, 25)

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
            } else {
                ProgressView("Loading room...")
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
            // ✅ Realtime listeners — بدل Timer كل 3 ثواني
            participantsListener = CloudKitManager.shared.listenToParticipants(roomCode: roomCode) { updated in
                participants = updated
            }
            roomListener = CloudKitManager.shared.listenToRoom(roomCode: roomCode) { data in
                if let isStarted = data["isStarted"] as? Bool, isStarted {
                    goToCamera = true
                }
                // حدّث mission للـ guest لو الهوست غيّرها
                if let room = rooms.first(where: { $0.code == roomCode }) {
                    room.missionTitle = data["missionTitle"] as? String
                    room.missionDescription = data["missionDescription"] as? String
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
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay {
                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: 20, weight: .bold))
                        }
                }
                Spacer()
                Text(name)
                    .font(.UbuntuBold(size: 18))
                    .foregroundColor(.black.opacity(0.8))
            }
        }
    }
}
