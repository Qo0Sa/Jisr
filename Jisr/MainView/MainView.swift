

//
//  MainView.swift
//  Jisr
//
//  Created by Sarah on 24/11/1447 AH.
//

import SwiftUI
import SwiftData


enum WaitingDestination: Hashable {
    case host
    case guest
    case profile
}

struct MainView: View {

    @State private var showRoomOptions = false
    
    @Environment(\.modelContext) private var context
    @Query private var rooms: [Room]
    
    @State private var viewModel   = MainViewModel()
   
    // لتفعيل ال بوب ابس
    @State private var isShowingCreatePopup = false
    @State private var isShowingJoinPopup = false
    
    
  
    @State private var waitingDestination: WaitingDestination? = nil
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                
                Color("Backgroundcolor").ignoresSafeArea()
                
                VStack(spacing: 0) {
                  
                    HStack {
                                     
                        // MARK: - 💡 اليسار: تم تحويل البروفايل لزر تفاعلي يقود لصفحة البروفايل بالملي
                                                Button {
                                                    withAnimation(.easeInOut(duration: 0.2)) {
                                                        waitingDestination = .profile
                                                    }
                                                } label: {
                                                    ProfileAvatarView(
                                                        image: viewModel.profileImage,
                                                        name: viewModel.userName
                                                    )
                                                }
                                                .buttonStyle(PlainButtonStyle()) // للحفاظ على الهوية البصرية للأفاتار بدون تلوين أزرق
                                                             
                                                Spacer()
                                     
                                     // اليمين
                                     Button {
                                            // action
                                        } label: {
                                            Image(systemName: "building.2.crop.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 45, height: 45)
                                                .foregroundColor(.button)
                                        }
                                     
                                 }
                                 .padding(.horizontal, 24)
                                 .padding(.top, 16)
                                 
                    
                    // MARK: - Empty State
                    if rooms.isEmpty {
                        EmptyRoomsView(showRoomOptions: $showRoomOptions)
                    } else {
                        Text("Your Rooms")
                             .font(.UbuntuBold(size: 26))
                             .foregroundColor(.black)
                             .frame(maxWidth: .infinity, alignment: .leading)
                             .padding(.horizontal, 24)
                             .padding(.top, 12)
                             .padding(.bottom, 4)
                        RoomsListView(rooms: rooms, showRoomOptions: $showRoomOptions)
                    }
                }
                
                
                if isShowingCreatePopup {
                                   // ← 3. أضف onRoomCreated
                                   RoomSelectionSheet(
                                       isPresented: $isShowingCreatePopup,
                                       onRoomCreated: {
                                           waitingDestination = .host
                                       }
                                   )
                                   .transition(.opacity)
                               }

                               if isShowingJoinPopup {
                                   // ← 4. أضف onJoined
                                   JoinWithCodeSheet(
                                       isPresented: $isShowingJoinPopup,
                                       onJoined: {
                                           waitingDestination = .guest
                                       }
                                   )
                                   .transition(.opacity)
                               }
                           }
            
            
            .navigationDestination(item: $waitingDestination) { destination in
                           switch destination {
                           case .host:
                               WaitingRoomView()
                           case .guest:
                               WaitingRoomForNotHostView()
                           case .profile:
                                               ProfileView()
                           }
                       }
                       .onAppear {
                           viewModel.loadUser(context: context)
                       }
                       .navigationBarBackButtonHidden(true)
                       .confirmationDialog(
                           "Room Options",
                           isPresented: $showRoomOptions,
                           titleVisibility: .visible
                       ) {
                           Button("Create a Room") {
                               withAnimation(.easeInOut(duration: 0.25)) {
                                   isShowingCreatePopup = true
                               }
                           }
                           Button("Join with Code") {
                               withAnimation(.easeInOut(duration: 0.25)) {
                                   isShowingJoinPopup = true
                               }
                           }
                           Button("Cancel", role: .cancel) { }
                       }
                   }
               }
           }

// MARK: - Empty State
struct EmptyRoomsView: View {
    
    @Binding var showRoomOptions: Bool
    
    var body: some View {
        
        VStack(spacing: 40) {
            
            // No Rooms Here Yet
            Text("No Rooms Here Yet")
                .font(.UbuntuBold(size: 24))
                .foregroundColor(.black)
                .padding(.top, 48)
                .padding(.bottom, 40)
            
            VStack(spacing: 0) {
                
                // كارد 1 - فاضية
                DashedCard { EmptyView() }
                
                // كارد 2 - فاضية (مع
                DashedCard { EmptyView() }
                    .opacity(0.6)
                    .scaleEffect(x: 0.95)
                
                // كارد 3 - زر الإضافة
                DashedCard {
                    Button {
                        showRoomOptions = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.black)
                    }
                }
                .zIndex(0)
                .opacity(0.4)
                .scaleEffect(x: 0.9)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - الكارد الـ Dashed
struct DashedCard<Content: View>: View {

    @ViewBuilder var content: Content

    var body: some View {

        ZStack {

            // Layer 3
            RoundedRectangle(cornerRadius: 28)
                .fill(Color("Backgroundcolor"))
                .frame(height: 150)
                .offset(y: 18)
                .scaleEffect(0.92)
                .shadow(
                    color: .black.opacity(0.04),
                    radius: 10,
                    y: 8
                )

            // Layer 2
            RoundedRectangle(cornerRadius: 28)
                .fill(Color("Backgroundcolor"))
                .frame(height: 150)
                .offset(y: 9)
                .scaleEffect(0.96)
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 12,
                    y: 6
                )

            // Main Card
            RoundedRectangle(cornerRadius: 28)
                .fill(Color("Backgroundcolor"))
                .frame(height: 150)
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: 2.5,
                                dash: [10, 6]
                            )
                        )
                        .foregroundColor(.black.opacity(0.65))
                }
                .shadow(
                    color: .black.opacity(0.08),
                    radius: 18,
                    y: 10
                )
                .rotation3DEffect(
                    .degrees(5),
                    axis: (x: 1, y: 0, z: 0)
                )

            content
        }
        .padding(.vertical, -18)
    }
}

// MARK: - لما يكون في رومات
struct RoomsListView: View {

    let rooms: [Room]
    @Binding var showRoomOptions: Bool

    var body: some View {

        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                
                ForEach(rooms) { room in
                    RoomCardView(room: room)
                }
                
                DashedCard {
                    Button {
                        showRoomOptions = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 25, weight: .light))
                    }
                }
                .opacity(0.6)
            }
            .padding(.horizontal, 24) // فقط مرة وحدة
            .padding(.top, 40)
        }
    }
}

// MARK: - كارد الروم
struct RoomCardView: View {
    
    let room: Room

    var cardColor: Color {
        switch room.category {
        case "Cognitive":
            return Color("cognitiveColor")

        case "Creative":
            return Color("creativeColor")

        default:
            return Color("physicalColor")
        }
    }

    var categoryIcons: [String] {
        switch room.category {
        case "Cognitive":
            return ["books.vertical.fill", "graduationcap.fill"]

        case "Creative":
            return ["paintpalette.fill", "music.note", "camera.fill"]

        default:
            return ["figure.run", "leaf.fill"]
        }
    }

    var body: some View {

        ZStack {
       

                // Layer 3
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(cardColor))
                    .frame(height: 150)
                    .offset(y: 18)
                    .scaleEffect(0.92)
                    .shadow(
                        color: .black.opacity(0.04),
                        radius: 10,
                        y: 8
                    )
            // Layer 3
//            RoundedRectangle(cornerRadius: 16)
//                .fill(cardColor)
//                .frame(height: 150)
            
            
            // Layer 2
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(cardColor))
                .frame(height: 150)
                .offset(y: 9)
                .scaleEffect(0.96)
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 12,
                    y: 6
                )

            // Main Card
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(cardColor))
                .frame(height: 150)
                .overlay(alignment: .topLeading) {

                    
                    //                    HStack(spacing: 10) {
                    //
                    //                        Circle()
                    //                            .fill(Color.white.opacity(0.25))
                    //                            .frame(width: 38, height: 38)
                    //                            .overlay {
                    //                                Image(systemName: "person.fill")
                    //                                    .foregroundColor(.white)
                    //                            }
                    //
                    //                        Text(room.name)
                    //                            .font(.UbuntuBold(size: 17))
                    //                            .foregroundColor(.white)
                    //                    }
                    //                    .padding(14)
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: 2.5,
                                dash: [10, 6]
                            )
                        )
                        .foregroundColor(.black.opacity(0.65))
                }
                .shadow(
                    color: .black.opacity(0.08),
                    radius: 18,
                    y: 10
                )
                .rotation3DEffect(
                    .degrees(5),
                    axis: (x: 1, y: 0, z: 0)
                )
            
                .overlay {

                    HStack(spacing: -10) {

                        ForEach(categoryIcons, id: \.self) { icon in

                            Image(systemName: icon)
                                .font(.system(size: 65, weight: .bold))
                                .foregroundColor(.white.opacity(0.14))
                                .rotationEffect(.degrees(-10))
                        }
                    }
                }
                .shadow(
                    color: cardColor.opacity(0.35),
                    radius: 18,
                    y: 10
                )
                .rotation3DEffect(
                    .degrees(5),
                    axis: (x: 1, y: 0, z: 0)
                )
        }
        .padding(.vertical, -18)
    }
}

    
// MARK: - صورة البروفايل الأصلية
struct ProfileAvatarView: View {
    let image: Image?
    let name: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.08))
                .frame(width: 52, height: 52)
            
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
            } else if !name.isEmpty {
                Text(String(name.prefix(1)).uppercased())
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black.opacity(0.6))
            } else {
                Image(systemName: "person.fill")
                    .foregroundColor(.black.opacity(0.3))
            }
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: [User.self, Room.self, Photo.self], inMemory: true)
}
