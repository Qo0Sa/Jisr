//
//  JoinWithCodeSheet.swift
//  Jisr
//

import SwiftUI
import SwiftData

struct JoinWithCodeSheet: View {
    @Binding var isPresented: Bool
    @State private var roomCode: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""

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
                    .background(Color("fieldColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 99))
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .focused($isTextFieldFocused)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                }

                Button(action: {
                    Task { await joinRoom() }
                }) {
                    if isLoading {
                        ProgressView()
                            .frame(width: 170, height: 58)
                            .background(Color("buttonColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                    } else {
                        Text("Join")
                            .font(.UbuntuBold(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 170)
                            .frame(height: 58)
                            .background(roomCode.isEmpty ? Color("buttonColor").opacity(0.5) : Color("buttonColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                    }
                }
                .disabled(roomCode.isEmpty || isLoading)
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
        .onAppear { isTextFieldFocused = true }
    }

    func joinRoom() async {
        isLoading = true
        errorMessage = ""

        guard let roomData = await CloudKitManager.shared.fetchRoom(byCode: roomCode) else {
            await MainActor.run {
                errorMessage = "❌ الكود غلط، تحقق منه"
                isLoading = false
            }
            return
        }

        let room = Room(
            name: roomData["name"] as? String ?? "",
            code: roomCode,
            category: roomData["category"] as? String ?? "",
            location: roomData["location"] as? String ?? "",
            maxPhotos: roomData["maxPhotos"] as? Int ?? 3
        )
        // ✅ احفظ mission للـ Guest مباشرة
        room.missionTitle = roomData["missionTitle"] as? String
        room.missionDescription = roomData["missionDescription"] as? String
        context.insert(room)

        let userDescriptor = FetchDescriptor<User>()
        if let currentUser = try? context.fetch(userDescriptor).first {
            await CloudKitManager.shared.addParticipant(
                roomCode: roomCode,
                userName: currentUser.name,
                profileImage: currentUser.profileImage,
                isHost: false
            )
        }

        try? context.save()
        // ✅ الجديد
        await MainActor.run {
            isPresented = false
            isLoading = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onJoined(room)
        }
    }
}

#Preview {
    JoinWithCodeSheet(isPresented: .constant(true))
}
