//
//  MainView.swift
//  Jisr
//
//  Created by Sarah on 24/11/1447 AH.
//

//import SwiftUI
//import SwiftData
//
//struct MainView: View {
//
//    @State private var showRoomOptions = false
//    
//    @Environment(\.modelContext) private var context
//    @Query private var rooms: [Room]
//    
//    @State private var viewModel   = MainViewModel()
//   
//    //for rooms
////    @State private var isShowingCreatePopup = false
////    @State private var isShowingJoinPopup = false
//    
//    var body: some View {
//        NavigationStack {
//            ZStack(alignment: .topLeading) {
//                
//                Color.backgroundcolor.ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                  
//                    // MARK: - صورة البروفايل يسار فوق
//                    HStack {
//                        ProfileAvatarView(
//                            image: viewModel.profileImage,
//                            name: viewModel.userName
//                        )
//                        Spacer()
//                    }
//                    .padding(.horizontal, 24)
//                    .padding(.top, 16)
//                    
//                    // MARK: - Empty State أو الكروت
//                    if rooms.isEmpty {
//                        EmptyRoomsView(showRoomOptions: $showRoomOptions)
//                    } else {
//                        RoomsListView(rooms: rooms, showRoomOptions: $showRoomOptions)
//                    }
//                }
//            }
//            .onAppear {
//                viewModel.loadUser(context: context)
//            }
//            .navigationBarBackButtonHidden(true)
//            
//            .confirmationDialog(
//                "Room Options",
//                isPresented: $showRoomOptions,
//                titleVisibility: .visible
//            ) {
//
//                Button("Create a Room") {
//                    showRoomOptions = true
//                }
//
//                Button("Join with Code") {
//
//                }
//
//                Button("Cancel", role: .cancel) { }
//            }
//            
//        }
//      
//    }
//}
//
//// MARK: - Empty State (اللي في الصورة)
//struct EmptyRoomsView: View {
//    
//    @Binding var showRoomOptions: Bool
//    
//    var body: some View {
//        
//        VStack(spacing: 40) {
//            
//            // No Rooms Here Yet
//            Text("No Rooms Here Yet")
//                .font(.UbuntuBold(size: 24))
//                .foregroundColor(.black)
//                .padding(.top, 48)
//                .padding(.bottom, 40)
//            
//            // 3 كروت dashed
//            VStack(spacing: 0) {
//                
//                // كارد 1 - فاضية
//                DashedCard { EmptyView() }
//                
//                // كارد 2 - فاضية (مع blur effect مثل الصورة)
//                DashedCard { EmptyView() }
//                    .opacity(0.6)
//                    .scaleEffect(x: 0.95)
//                
//                // كارد 3 - زر الإضافة
//                DashedCard {
//                    Button {
//                        showRoomOptions = true
//                    } label: {
//                        Image(systemName: "plus")
//                            .font(.system(size: 32, weight: .light))
//                            .foregroundColor(.black)
//                    }
//                }
//                .opacity(0.4)
//                .scaleEffect(x: 0.9)
//            }
//            .padding(.horizontal, 40)
//            
//         
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//    }
//}
//
//
//// MARK: - الكارد الـ Dashed
//struct DashedCard<Content: View>: View {
//
//    @ViewBuilder var content: Content
//
//    var body: some View {
//
//        ZStack {
//
//            // Layer 3
//            RoundedRectangle(cornerRadius: 28)
//                .fill(Color.backgroundcolor)
//                .frame(height: 150)
//                .offset(y: 18)
//                .scaleEffect(0.92)
//                .shadow(
//                    color: .black.opacity(0.04),
//                    radius: 10,
//                    y: 8
//                )
//
//            // Layer 2
//            RoundedRectangle(cornerRadius: 28)
//                .fill(Color.backgroundcolor)
//                .frame(height: 150)
//                .offset(y: 9)
//                .scaleEffect(0.96)
//                .shadow(
//                    color: .black.opacity(0.05),
//                    radius: 12,
//                    y: 6
//                )
//
//            // Main Card
//            RoundedRectangle(cornerRadius: 28)
//                .fill(Color.backgroundcolor)
//                .frame(height: 150)
//                .overlay {
//                    RoundedRectangle(cornerRadius: 28)
//                        .strokeBorder(
//                            style: StrokeStyle(
//                                lineWidth: 2.5,
//                                dash: [10, 6]
//                            )
//                        )
//                        .foregroundColor(.black.opacity(0.65))
//                }
//                .shadow(
//                    color: .black.opacity(0.08),
//                    radius: 18,
//                    y: 10
//                )
//                .rotation3DEffect(
//                    .degrees(5),
//                    axis: (x: 1, y: 0, z: 0)
//                )
//
//            content
//        }
//        .padding(.vertical, -18)
//    }
//}
//
//// MARK: - لما يكون في رومات (قائمة عادية)
//struct RoomsListView: View {
//    
//    let rooms: [Room]
//    @Binding var showRoomOptions: Bool
//    
//    let columns = [GridItem(.flexible()), GridItem(.flexible())]
//    
//    var body: some View {
//        ScrollView {
//            LazyVGrid(columns: columns, spacing: 16) {
//                
//                ForEach(rooms) { room in
//                    RoomCardView(room: room)
//                }
//                
//                // زر إضافة روم جديد
//                Button { showRoomOptions = true } label: {
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(Color.field)
//                        .frame(height: 180)
//                        .overlay {
//                            VStack(spacing: 8) {
//                                ZStack {
//                                    Circle()
//                                        .fill(Color.black)
//                                        .frame(width: 44, height: 44)
//                                    Image(systemName: "plus")
//                                        .foregroundColor(.white)
//                                        .font(.system(size: 20, weight: .semibold))
//                                }
//                                Text("New Room")
//                                    .font(.caption)
//                                    .foregroundColor(.black.opacity(0.5))
//                            }
//                        }
//                }
//            }
//            .padding(.horizontal, 24)
//            .padding(.top, 16)
//            .padding(.bottom, 32)
//        }
//    }
//}
//
//
//// MARK: - كارد الروم الموجود
//struct RoomCardView: View {
//    let room: Room
//    
//    var body: some View {
//        RoundedRectangle(cornerRadius: 20)
//            .fill(Color.field)
//            .frame(height: 180)
//            .overlay {
//                VStack(spacing: 8) {
//                    Image(systemName: "photo.on.rectangle.angled")
//                        .font(.system(size: 30))
//                        .foregroundColor(.black.opacity(0.2))
//                    Text(room.name)
//                        .font(.UbuntuBold(size: 14))
//                        .foregroundColor(.black.opacity(0.6))
//                        .lineLimit(1)
//                    Text(room.code)
//                        .font(.system(size: 11, design: .monospaced))
//                        .foregroundColor(.black.opacity(0.3))
//                }
//                .padding()
//            }
//    }
//}
//
//// MARK: - صورة البروفايل
//struct ProfileAvatarView: View {
//    let image: Image?
//    let name: String
//    
//    var body: some View {
//        ZStack {
//            Circle()
//                .fill(Color.black.opacity(0.08))
//                .frame(width: 52, height: 52)
//            
//            if let image {
//                image
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 52, height: 52)
//                    .clipShape(Circle())
//            } else if !name.isEmpty {
//                Text(String(name.prefix(1)).uppercased())
//                    .font(.system(size: 22, weight: .bold))
//                    .foregroundColor(.black.opacity(0.6))
//            } else {
//                Image(systemName: "person.fill")
//                    .foregroundColor(.black.opacity(0.3))
//            }
//        }
//        
//    }
//}
//
//
//
//
//#Preview {
//    MainView()
//        .modelContainer(for: [User.self, Room.self, Photo.self], inMemory: true)
//}











//
//  MainView.swift
//  Jisr
//
//  Created by Sarah on 24/11/1447 AH.
//

import SwiftUI
import SwiftData

struct MainView: View {

    @State private var showRoomOptions = false
    
    @Environment(\.modelContext) private var context
    @Query private var rooms: [Room]
    
    @State private var viewModel   = MainViewModel()
   
    // لتفعيل ال بوب ابس
    @State private var isShowingCreatePopup = false
    @State private var isShowingJoinPopup = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                
                Color("Backgroundcolor").ignoresSafeArea()
                
                VStack(spacing: 0) {
                  
                    // MARK: -  البروفايل
                    HStack {
                        ProfileAvatarView(
                            image: viewModel.profileImage,
                            name: viewModel.userName
                        )
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // MARK: - Empty State
                    if rooms.isEmpty {
                        EmptyRoomsView(showRoomOptions: $showRoomOptions)
                    } else {
                        RoomsListView(rooms: rooms, showRoomOptions: $showRoomOptions)
                    }
                }
                
                if isShowingCreatePopup {
                    RoomSelectionSheet(isPresented: $isShowingCreatePopup)
                        .transition(.opacity)
                }

                if isShowingJoinPopup {
                    JoinWithCodeSheet(isPresented: $isShowingJoinPopup)
                        .transition(.opacity)
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
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                
                ForEach(rooms) { room in
                    RoomCardView(room: room)
                }
                
                // زر إضافة روم جديد
                Button { showRoomOptions = true } label: {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("fieldColor"))
                        .frame(height: 180)
                        .overlay {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .semibold))
                                }
                                Text("New Room")
                                    .font(.caption)
                                    .foregroundColor(.black.opacity(0.5))
                            }
                        }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - كارد الروم الموجود
struct RoomCardView: View {
    let room: Room
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color("fieldColor"))
            .frame(height: 180)
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 30))
                        .foregroundColor(.black.opacity(0.2))
                    Text(room.name)
                        .font(.UbuntuBold(size: 14))
                        .foregroundColor(.black.opacity(0.6))
                        .lineLimit(1)
                    Text(room.code)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.black.opacity(0.3))
                }
                .padding()
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
        .modelContainer(for: [User.self, Room.self, Photo.self], inMemory: true)
}
