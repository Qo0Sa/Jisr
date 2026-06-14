//
//  hostView.swift
//  Jisr
//

import SwiftUI
import CoreML
import SwiftData
import FirebaseFirestore

struct WaitingRoomView: View {
    
    @Binding var waitingDestination: WaitingDestination?
    @State private var copied = false
    var isStarted: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    let room: Room
    
    @State private var missionTitle = ""
    @State private var missionDescription = ""
    
    var backgroundImageName: String {
        switch room.category {
        case "Cognitive": return "bluebg"
        case "Physical":  return "greenbg"
        default:          return "yellowbg"
        }
    }
    
    var backgroundForBtn: String {
        switch room.category {
        case "Cognitive": return "backbtnblue"
        case "Physical":  return "blackbtngreen"
        default:          return "back bg"
        }
    }
    
    @State private var goToCamera = false
    @State private var isStartingRoom = false
    @State private var participants: [[String: Any]] = []
    @State private var roomListener: ListenerRegistration? = nil
    @State private var participantsListener: ListenerRegistration? = nil
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                
                VStack {
                    
                    HStack {
                        Button(action: { dismiss() }) {
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
                            Text(missionTitle)
                                .font(.system(size: 20))
                                .foregroundColor(.black.opacity(0.75))

                            Spacer()

                            Button(action: { generateMission() }) {
                                Image(systemName: "arrow.trianglehead.2.clockwise")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black.opacity(0.75))
                            }
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
                    
                    
                    
                    
                    HStack {
                        Label("\(participants.count)", systemImage: "person.fill")
                        
                        HStack {
                            Text(room.code).foregroundColor(.gray)
                            Button(action: {
                                UIPasteboard.general.string = room.code
                                withAnimation { copied = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation { copied = false }
                                }
                            }) {
                                Image(systemName: copied ? "checkmark" : "document.on.document")
                                    .foregroundColor(copied ? .green : .gray)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                        }
                        .padding(.horizontal, 55)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(20)
                        
                        ShareLink(
                            item: """
                            Join my room in Jisr
                            
                            Room Code: \(room.code)
                            
                            Mission:
                            \(room.missionTitle ?? missionTitle)
                            
                            \(room.missionDescription ?? missionDescription)
                            """
                        ) {
                            Image(systemName: "square.and.arrow.up")
                                .padding(8)
                                .foregroundColor(.black)
                        }
                    }
                    .offset(y: -100)
                }
                .padding(.horizontal, 25)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        ForEach(Array(participants.enumerated()), id: \.offset) { _, participant in
                            UserCard(
                                name: participant["userName"] as? String ?? "Unknown",
                                profileImageData: participant["profileImageData"] as? Data                            )
                        }
                        Color.clear.frame(height: 30)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 40)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .offset(y: -90)
            }
            
            VStack {
                ZStack(alignment: .bottom) {
                    Image(backgroundForBtn)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipped()
                    
                    Button(action: {
                        guard !isStartingRoom else { return }
                        isStartingRoom = true
                        room.isStarted = true
                        room.missionTitle = missionTitle
                        room.missionDescription = missionDescription
                        try? context.save()
                        // ✅ الجديد
                        Task {
                            await CloudKitManager.shared.updateRoom(
                                roomCode: room.code,
                                isStarted: true,
                                missionTitle: missionTitle,
                                missionDescription: missionDescription
                            )
                            await MainActor.run {
                                isStartingRoom = false
                                goToCamera = true
                            }
                        }
                        
                        goToCamera = true
                    }) {
                        Group {
                            if isStartingRoom {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Start")
                                    .font(.UbuntuBold(size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 220, height: 65)
                        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                        .cornerRadius(35)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isStartingRoom)
                    .padding(.bottom, 40)
                }
                .ignoresSafeArea()
            }
        }
        .navigationDestination(isPresented: $goToCamera) {
            CameraView(room: room, isHost: true)
        }
        .navigationBarHidden(true)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissRoomFlow"))) { _ in
            goToCamera = false
        }
        .onAppear {
            if missionTitle.isEmpty {
                generateMission()
            }
            // ✅ Realtime listener بدل Timer
            participantsListener = CloudKitManager.shared.listenToParticipants(roomCode: room.code) { updated in
                print("🎯 HOST UI UPDATED")
                print("🎯 participants count = \(updated.count)")
                participants = updated
            }
        }
        .onDisappear {
            participantsListener?.remove()
            roomListener?.remove()
        }
    }
    
    func generateMission() {
        do {
            let config = MLModelConfiguration()
            let model = try jisr_test_1(configuration: config)
            let output = try model.prediction(Category: room.category, Location_Type: room.location)
            let availablePrompts = Array(output.PromptProbability.keys)
            let chosenPrompt = availablePrompts.randomElement() ?? output.Prompt
            if let openParen = chosenPrompt.firstIndex(of: "("),
               let closeParen = chosenPrompt.lastIndex(of: ")") {
                let title = String(chosenPrompt[..<openParen]).trimmingCharacters(in: .whitespaces)
                let descStart = chosenPrompt.index(after: openParen)
                let description = String(chosenPrompt[descStart..<closeParen]).trimmingCharacters(in: .whitespaces)
                missionTitle = title
                missionDescription = description
                room.missionTitle = title
                room.missionDescription = description
                try? context.save()
                Task {
                    await CloudKitManager.shared.updateRoom(
                        roomCode: room.code,
                        missionTitle: title,
                        missionDescription: description
                    )
                }
            } else {
                missionTitle = "Mission"
                missionDescription = chosenPrompt
            }
        } catch {
            missionDescription = "Could not load mission."
            missionTitle = "Mission"
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

#Preview {
    let previewRoom = Room(name: "Creative Room", code: "ABC-123", category: "Creative", location: "Outdoor", maxPhotos: 5)
    WaitingRoomView(waitingDestination: .constant(nil), room: previewRoom)
}
