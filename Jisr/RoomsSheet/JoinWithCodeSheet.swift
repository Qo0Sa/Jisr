//
//  JoinWithCodeSheet.swift
//  Jisr
//
//  Created by Wteen on 25/11/1447 AH.
//

import SwiftUI
import SwiftData


struct JoinWithCodeSheet: View {
    @Binding var isPresented: Bool
    @State private var roomCode: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
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
                    isPresented = false
//                    onJoined()
                    //wed
                    let descriptor = FetchDescriptor<Room>()

                       if let room = try? context.fetch(descriptor)
                           .first(where: { $0.code == roomCode }) {

                           onJoined(room)
                           isPresented = false
                       }
                }) {
                    Text("Join")
                        .font(.UbuntuBold(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 170)
                        .frame(height: 58)
                        .background(roomCode.isEmpty ? Color("buttonColor").opacity(0.5) : Color("buttonColor"))
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
}

#Preview {
    JoinWithCodeSheet(isPresented: .constant(true))
}
