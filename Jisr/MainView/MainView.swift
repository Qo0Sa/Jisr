//
//  MainView.swift
//  Jisr
//
//  Created by Sarah on 24/11/1447 AH.
//

import SwiftUI
import SwiftData
import FirebaseFirestore

enum WaitingDestination: Hashable {
    case host
    case guest
    case profile
    case hostGame  // wteen
    case guestGame // wteen
    
    var id: Self { self }
}

struct MainView: View {

    @EnvironmentObject private var layerState: LayerState
    @Environment(\.scenePhase) private var scenePhase

    @State private var showRoomOptions = false
    @State private var showModelPage = false

    @Environment(\.modelContext) private var context
    
    // 💡 فلترة واستبعاد الغرف التاريخية المغلقة من الواجهة الرئيسية فور إنهاء الروم حياً
    @Query(filter: #Predicate<Room> { room in
        room.isClosed == false
    }) private var rooms: [Room]

    // All rooms (open + closed) — used only for layer sync so closed rooms still earn layers
    @Query private var allRooms: [Room]

    @Query private var users: [User]

    @State private var viewModel = MainViewModel()

    @State private var isShowingCreatePopup = false
    @State private var isShowingJoinPopup = false

    @State private var waitingDestination: WaitingDestination? = nil
    @State private var createdRoom: Room? = nil
    @State private var joinedRoom: Room? = nil
    
    // Extracted to reduce type-checking complexity inside .navigationDestination
    @ViewBuilder
    private func destinationView(for destination: WaitingDestination) -> some View {
        switch destination {
        case .host:
            if let room = createdRoom {
                WaitingRoomView(waitingDestination: $waitingDestination, room: room)
            } else {
                Text("Preparing room...")
            }
            // ✅ الجديد
            case .guest:
                if let room = joinedRoom {
                    WaitingRoomForNotHostView(roomCode: room.code)
                } else {
                    Text("No active room joined.")
                }
            
        case .profile:
            ProfileView(waitingDestination: $waitingDestination)
        case .hostGame:
            if let room = createdRoom {
                CameraView(room: room, isHost: true)
            } else {
                Text("Preparing host game…")
            }
        case .guestGame:
            if let room = createdRoom {
                CameraView(room: room, isHost: false)
            } else if let fallbackRoom = rooms.first {
                CameraView(room: fallbackRoom, isHost: false)
            } else {
                Text("Preparing guest game…")
            }
        }
    }
    
    private var currentUserImage: Image? {
        if let data = users.first?.profileImage, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                
                Color("Backgroundcolor").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                waitingDestination = .profile
                            }
                        } label: {
                            ProfileAvatarView(
                                image: currentUserImage,
                                name: users.first?.name ?? viewModel.userName
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                                                             
                        Spacer()
                                     
                        Button {
                            showModelPage = true
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
                
                // ✅ الجديد
                if isShowingCreatePopup {
                    RoomSelectionSheet(
                        isPresented: $isShowingCreatePopup,
                        onRoomCreated: { room in
                            createdRoom = room
                            isShowingCreatePopup = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                waitingDestination = .host
                            }
                        }
                    )
                    .transition(.opacity)
                }
                // ✅ الكود الجديد
                if isShowingJoinPopup {
                    JoinWithCodeSheet(
                        isPresented: $isShowingJoinPopup,
                        // ✅ الجديد
                        onJoined: { room in
                            joinedRoom = room
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                waitingDestination = .guest
                            }
                        }
                    )
                }
            }
            .navigationDestination(item: $waitingDestination) { destination in
                destinationView(for: destination)
            }
            .navigationDestination(isPresented: $showModelPage) {
                ModelPage()
            }
            .onAppear {
                viewModel.loadUser(context: context)
                layerState.syncWithRooms(allRooms, maxLayers: 18)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissRoomFlow"))) { _ in
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.waitingDestination = nil
                }
                // Sync immediately when returning from a room flow — the room
                // is already closed by this point, so we need allRooms here.
                layerState.syncWithRooms(allRooms, maxLayers: 18)
            }
            .onChange(of: allRooms) { _, latest in
                layerState.syncWithRooms(latest, maxLayers: 18)
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    layerState.checkWeeklyExpiry(maxLayers: 18)
                    layerState.syncWithRooms(allRooms, maxLayers: 18)
                }
            }
            .navigationBarBackButtonHidden(true)
            .confirmationDialog("Room Options", isPresented: $showRoomOptions, titleVisibility: .visible) {
                Button("Create a Room") {
                    withAnimation(.easeInOut(duration: 0.25)) { isShowingCreatePopup = true }
                }
                Button("Join with Code") {
                    withAnimation(.easeInOut(duration: 0.25)) { isShowingJoinPopup = true }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        .onAppear {
            let descriptor = FetchDescriptor<Room>()
            let rooms = try? context.fetch(descriptor)
            print("عدد الرومز: \(rooms?.count ?? 0)")
            rooms?.forEach { print("روم: \($0.name) - كود: \($0.code)") }
        }
    }
}

// MARK: - Subviews
struct EmptyRoomsView: View {
    @Binding var showRoomOptions: Bool
    var body: some View {
        VStack(spacing: 40) {
            Text("No Rooms Here Yet")
                .font(.UbuntuBold(size: 24))
                .foregroundColor(.black)
                .padding(.top, 48)
                .padding(.bottom, 40)
            
            VStack(spacing: 0) {
                DashedCard { EmptyView() }
                DashedCard { EmptyView() }
                    .opacity(0.6)
                    .scaleEffect(x: 0.95)
                DashedCard {
                    Button { showRoomOptions = true } label: {
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

struct DashedCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28).fill(Color("Backgroundcolor")).frame(height: 150).offset(y: 18).scaleEffect(0.92).shadow(color: .black.opacity(0.04), radius: 10, y: 8)
            RoundedRectangle(cornerRadius: 28).fill(Color("Backgroundcolor")).frame(height: 150).offset(y: 9).scaleEffect(0.96).shadow(color: .black.opacity(0.05), radius: 12, y: 6)
            RoundedRectangle(cornerRadius: 28).fill(Color("Backgroundcolor")).frame(height: 150)
                .overlay { RoundedRectangle(cornerRadius: 28).strokeBorder(style: StrokeStyle(lineWidth: 2.5, dash: [10, 6])).foregroundColor(.black.opacity(0.65)) }
                .shadow(color: .black.opacity(0.08), radius: 18, y: 10).rotation3DEffect(.degrees(5), axis: (x: 1, y: 0, z: 0))
            content
        }.padding(.vertical, -18)
    }
}

struct RoomsListView: View {
    let rooms: [Room]
    @Binding var showRoomOptions: Bool
    @Query private var users: [User]  // ← أضف هذا

    var body: some View {

        ScrollView(showsIndicators: false) {
            VStack(spacing: -40) {  // ← spacing سالب عشان يتغطى
                
//                ForEach(Array(rooms.enumerated()), id: \.element.id) { index, room in
//                    let isHost = room.createdBy?.persistentModelID == users.first?.persistentModelID
//                    
//                    NavigationLink(destination: {
//                        if room.isStarted {
//                            CameraView(room: room, isHost: isHost)
//                        } else {
//                            if isHost {
//                                WaitingRoomView(waitingDestination: .constant(nil), room: room)
//                            } else {
////                                WaitingRoomForNotHostView(room: room)
//                                WaitingRoomForNotHostView(roomCode: room.code)
//                            }
//                        }
//                    }) {
//                        RoomCardView(room: room)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                    .zIndex(Double(index))
//                }
                ForEach(Array(rooms.enumerated()), id: \.element.id) { index, room in
                    NavigationLink {
                        destinationView(for: room, users: users)
                    } label: {
                        RoomCardView(room: room)
                    }
                    .buttonStyle(.plain)
                    .zIndex(Double(index))
                }
                
                
                DashedCard {
                    Button {
                        showRoomOptions = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 20)
                .opacity(0.6)
                .zIndex(Double(rooms.count + 1))
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
        }
    }
    
    @ViewBuilder
    private func destinationView(for room: Room, users: [User]) -> some View {
        let isHost = (room.createdBy?.persistentModelID == users.first?.persistentModelID)

        if room.isStarted {
            CameraView(room: room, isHost: isHost)
        } else {
            if isHost {
                WaitingRoomView(waitingDestination: .constant(nil), room: room)
            } else {
                WaitingRoomForNotHostView(roomCode: room.code)
            }
        }
    }
}
// MARK: - كارد الروم
struct RoomCardView: View {
    
    let room: Room

    var categoryIconColor: Color {
        guard room.isStarted else {
            return Color(.systemGray3)
        }
        
        switch room.category {
        case "Cognitive":
            return Color("conicon")
        case "Creative":
            return Color("cricon")
        default:
            return Color("phicon")
        }
    }
    
    var cardColor: Color {
        guard room.isStarted else {
            return Color(.systemGray4)  // ← رمادي لو ما بدأت
        }
        
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
            return ["books.vertical.fill", "graduationcap.fill", "puzzlepiece.fill"]

        case "Creative":
            return ["paintpalette.fill", "music.note", "camera.fill"]

        default:
            return ["figure.run", "leaf.fill", "soccerball"]
        }
    }

    var body: some View {

        ZStack {
       

                // Layer 3
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(cardColor))
                    .frame(width: 333, height: 186)
                    .offset(y: 10)
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
                .frame(width: 333, height: 186)
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
                .frame(width: 333, height: 186)
                .overlay(alignment: .topLeading) {

                    
                   
                   
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
                    VStack(alignment: .leading) {
                        
                        // ← اسم الروم + صورة الهوست في الزاوية العلوية اليسرى
                        HStack(spacing: 8) {
                            RoomHostAvatar(room: room)
                            
                            // اسم الروم
                            Text(room.name)
                                .font(.UbuntuBold(size: 22))
                                .foregroundColor(room.isStarted ? .button : .button)
                        }
                        .padding(14)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // الأيقونات في الخلفية
                    VStack(spacing: -15) {
                        // صفين أيقونتين فوق
                        HStack(spacing: -10) {
                            ForEach(categoryIcons.prefix(2), id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.system(size: 55, weight: .bold))
                                    .foregroundColor(categoryIconColor)
                                    .rotationEffect(.degrees(-10))
                            }
                        }
                        
                        // الأيقونة الثالثة في المنتصف
                        if categoryIcons.count > 2 {
                            Image(systemName: categoryIcons[2])
                                .font(.system(size: 55, weight: .bold))
                                .foregroundColor(categoryIconColor)
                                .rotationEffect(.degrees(-10))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 10)                }

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
        .padding(.vertical, 0)
        
    }
}

struct RoomHostAvatar: View {
    let room: Room

    @State private var hostImageData: Data?
    @State private var hostInitial: String = ""
    @State private var listener: ListenerRegistration?

    var body: some View {
        Group {
            if let imageData = room.createdBy?.profileImage ?? hostImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if !hostInitial.isEmpty {
                Text(hostInitial)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
            } else {
                Image(systemName: "person.fill")
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(width: 38, height: 38)
        .background(Color.white.opacity(0.4))
        .clipShape(Circle())
        .onAppear {
            guard room.createdBy?.profileImage == nil else { return }
            listener?.remove()
            listener = Firestore.firestore()
                .collection("participants")
                .whereField("roomCode", isEqualTo: room.code)
                .whereField("isHost", isEqualTo: true)
                .addSnapshotListener { snapshot, error in
                    if let error {
                        print("❌ host avatar listener: \(error)")
                        return
                    }

                    guard let data = snapshot?.documents.first?.data() else { return }
                    if let data = data["profileImageData"] as? Data {
                        hostImageData = data
                    }
                    if let name = data["userName"] as? String {
                        hostInitial = String(name.prefix(1)).uppercased()
                    }
                }
        }
        .onDisappear {
            listener?.remove()
            listener = nil
        }
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
        .environmentObject(LayerState())
        .modelContainer(for: [User.self, Room.self, Photo.self], inMemory: true)
    
    
}

