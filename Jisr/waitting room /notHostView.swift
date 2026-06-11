////
////  notHostView.swift
////  Jisr
////
////  Created by Wed Ahmed Alasiri on 17/05/2026.
////
//
//
//
//import SwiftUI
//import SwiftData
//
//struct WaitingRoomForNotHostView: View {
//
////    let room: Room
//    let roomCode: String
//    
//    @State private var goToCamera = false
//    
//    @State private var goToMain = false
//    
//    @Query private var rooms: [Room]
//
//    var room: Room? {
//        rooms.first(where: { $0.code == roomCode })
//    }
//    var body: some View {
//        if let room {
//            Text(room.name)
//        }
//       
//        ZStack(alignment: .bottom) { // جعل العناصر تترتب فوق بعضها
//            
//            // 1. الخلفية الثابتة
//            Image("yellowbg")
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
//            
//            // 2. المحتوى الأساسي
//            VStack {
//                
//                
//                // MARK: Header & Mission & Code (العناصر الثابتة في الأعلى)
//                VStack {
//                    
//                    // الهيدر
//                    HStack {
//                        Button(action: {
//                            goToMain = true
//
//                        }) {
//                            Image(systemName: "chevron.left")
//                                .font(.system(size: 24, weight: .bold))
//                                .foregroundColor(.black)
//                        }
//                        Spacer()
//                        Text(room.name)
//                            .font(.system(size: 22, weight: .bold))
//                        Spacer()
//                        Color.clear.frame(width: 24)
//                    }
//                    //                    .padding(.top, 10)
//                    .offset(y:-30)
//                    
//                    // بطاقة المهمة
//                    VStack(alignment: .leading, spacing: 12) {
//                        
//                        HStack(alignment: .top) {
//                            
//                            Text(room.missionTitle ?? "")
//                                .font(.system(size: 20, weight: .medium))
//                                .foregroundColor(.black.opacity(0.75))
//                            
//                            Spacer()
//                            //                                    Button(action: {
//                            //
//                            //                                        }) {
//                            Image(systemName: "arrow.trianglehead.2.clockwise")
//                                .font(.system(size: 20))
//                                .foregroundColor(.black.opacity(0.75))
//                            //                                            }
//                            //                                        }
//                            
//                            Text(room.missionDescription ?? "")
//                                .font(.system(size: 14))
//                                .foregroundColor(.black.opacity(0.7))
//                                .padding(16)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .background(Color(red: 233/255, green: 227/255, blue: 214/255))
//                                .cornerRadius(18)
//                            
//                        }
//                        .padding(16)
//                        .background(Color(red: 244/255, green: 242/255, blue: 237/255))
//                        .cornerRadius(24)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 24)
//                                .stroke(Color.black.opacity(0.7), lineWidth: 1)
//                        )
//                        .shadow(color: .black.opacity(0.4), radius: 0, x: 0, y: 3)
//                        .padding(.horizontal, -10)
//                        //         .padding(.top, 22)
//                        .offset(y: -120)
//                        
//                        // زر النسخ (نهاية العناصر الثابتة)
//                        HStack {
//                            Label("5", systemImage: "person.fill")
//                            
//                        }
//                        .offset(y:-100)
//                        
//                    }
//                    .padding(.horizontal, 25)
//                    
//                    
//                    // MARK: ScrollView (تبدأ من هنا وتأخذ باقي الشاشة)
//                    ScrollView(showsIndicators: false) {
//                        VStack(spacing: 15) {
//
//                            ForEach(room.participants, id: \.persistentModelID) { participant in
//                                UserCard(
//                                    name: participant.user?.name ?? "Unknown",
//                                    imageData: participant.user?.profileImage
//                                )
//                            }
//                            }
//
//                            Color.clear.frame(height: 30)
//                        }
//                        .padding(.horizontal)
//                        .padding(.vertical, 40)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .offset(y:-90)
//                    
//                }
//                
//                
//            }
//        }
//        
//        .navigationDestination(isPresented: $goToCamera) {
//            CameraView(
//                room: room,
//                isHost: false
//            )
//        }
//        .onChange(of: room.isStarted) { _, started in
//            if started {
//                goToCamera = true
//            }
//        }
//        .navigationDestination(isPresented: $goToMain) {
//            MainView()
//        }
//        .navigationBarHidden(true)
//        
//        .onChange(of: room.isStarted) { _, started in
//            if started {
//                goToCamera = true
//            }
//        }
//    }
//        // كرت المستخدم (نفسه بدون تغيير)
//struct UserCard: View {
//    let name: String
//    let imageData: Data?
//
//    var body: some View {
//        HStack(spacing: 15) {
//
//            if let imageData,
//               let uiImage = UIImage(data: imageData) {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 60, height: 60)
//                    .clipShape(Circle())
//            } else {
//                Circle()
//                    .fill(Color.gray.opacity(0.2))
//                    .frame(width: 60, height: 60)
//                    .overlay {
//                        Text(String(name.prefix(1)).uppercased())
//                    }
//            }
//
//            Spacer()
//
//            Text(name)
//                .font(.system(size: 18, weight: .bold))
//        }
//    }
//}
//    
//    
////
////#Preview {
////    WaitingRoomForNotHostView(room: <#Room#>)
////}
// 

import SwiftUI
import SwiftData
import CloudKit


struct WaitingRoomForNotHostView: View {

    let roomCode: String

    @State private var goToCamera = false
    @State private var goToMain = false
    
    @State private var ckParticipants: [CKRecord] = []
    @State private var ckRoom: CKRecord? = nil
    @State private var refreshTimer: Timer? = nil
    
    
    @Query private var rooms: [Room]

    var room: Room? {
        rooms.first(where: { $0.code == roomCode })
    }

    var body: some View {
        Group {
            if let room = room {

                ZStack(alignment: .bottom) {

                    Image("yellowbg")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    VStack {

                        VStack {

                            // HEADER
                            HStack {
                                Button(action: {
                                    goToMain = true
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.black)
                                }

                                Spacer()

                                Text(room.name)
                                    .font(.system(size: 22, weight: .bold))

                                Spacer()

                                Color.clear.frame(width: 24)
                            }
                            .offset(y: -30)

                            // MISSION CARD
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.black.opacity(0.7), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.4), radius: 0, x: 0, y: 3)
                            .padding(.horizontal, -10)
                            .offset(y: -120)

                            // PARTICIPANTS COUNT
                            HStack {
                                Label("\(ckParticipants.count)", systemImage: "person.fill")
                            }
                            .offset(y: -100)

                        }
                        .padding(.horizontal, 25)

                        // LIST
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 15) {

                                ForEach(ckParticipants, id: \.recordID) { participant in
                                    UserCard(
                                        name: participant["CD_userName"] as? String ?? "Unknown",
                                        imageData: participant["CD_userProfileImage"] as? Data
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
                // 👇 fallback مهم عشان ما ينهار UI لو الروم ما وصل بعد
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
            loadData()
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                loadData()
            }
        }
        .onDisappear {
            refreshTimer?.invalidate()
        }
        
        
        .onReceive(NotificationCenter.default.publisher(for: .cloudKitDataChanged)) { _ in
            loadData()
        }
    }

    func loadData() {
        Task {
            ckParticipants = await CloudKitManager.shared.fetchParticipants(roomCode: roomCode)
            ckRoom = await CloudKitManager.shared.fetchRoom(byCode: roomCode)
            if let ckRoom,
               (ckRoom["CD_isStarted"] as? Int == 1 || ckRoom["CD_isStarted"] as? Int64 == 1) {
                await MainActor.run { goToCamera = true }
            }
        }
    }
    
    // MARK: - User Card (بدون تغيير)
    struct UserCard: View {

        let name: String
        let imageData: Data?

        var body: some View {
            HStack(spacing: 15) {

                if let imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
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
                        }
                }

                Spacer()

                Text(name)
                    .font(.system(size: 18, weight: .bold))
            }
        }
    }
}
