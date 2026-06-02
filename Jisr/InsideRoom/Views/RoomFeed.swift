//
//  RoomFeed.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//

//
//  RoomFeed.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 01/12/1447 AH.
//

import SwiftUI
import SwiftData

struct RoomFeed: View {
    @Environment(\.modelContext) private var context
    
    let room: Room
    let isHost: Bool
    @Binding var isShowingFeed: Bool
    
    @State private var isShowingEndPopup = false
    @State private var isRoomFinished = false
    
    // جلب الصور المرتبطة بهذه الغرفة حياً من قاعدة البيانات وترتيبها بالأحدث
    var roomPhotos: [Photo] {
        let allPhotos = room.photos ?? []
        return allPhotos.sorted(by: { $0.uploadedAt > $1.uploadedAt })
    }
    
    // (Grid)
    let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 1. (الأفاتارات المتداخلة والعداد الحي)
                RoomHeader(
                    currentProgress: roomPhotos.count,
                    maxPhotos: room.maxPhotos,
                    isShowingFeed: isShowingFeed,
                    onGalleryToggle: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isShowingFeed = false
                        }
                    }
                )
                
                // 2. معرض الصور المشترك
                ScrollView(.vertical, showsIndicators: false) {
                    if roomPhotos.isEmpty {
                        VStack(spacing: 12) {
                            Spacer().frame(height: 120)
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 48))
                                .foregroundColor(.black.opacity(0.12))
                            Text("No photos captured yet")
                                .font(.UbuntuBold(size: 16))
                                .foregroundColor(.black.opacity(0.4))
                            Text("Switch to camera and capture the first moment!")
                                .font(.Ubuntu(size: 13))
                                .foregroundColor(.black.opacity(0.3))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)
                    } else {
                    
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(roomPhotos) { photo in
                                FeedCard(
                                    userName: photo.user?.name ?? "Member",
                                    thoughtText: "Capturing the moment!",
                                    emojiReaction: "✨"
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 100) // مسافة آمنة لضمان عدم حجب الكروت السفلية بالزر
                    }
                }
            }
            
            // 3. زر إنهاء الروم السفلي (يظهر حراً عائماً في الأسفل للهوست فقط)
            if isHost {
                VStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isShowingEndPopup = true
                        }
                    }) {
                        Text("End Room")
                            .font(.UbuntuBold(size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(Color(red: 0.18, green: 0.18, blue: 0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
            }
            
            // 4. استدعاء نافذة التأكيد المنبثقة للإنهاء عند طلبها
            if isShowingEndPopup {
                EndRoomPopup(
                    isPresented: $isShowingEndPopup,
                    onConfirmEnd: {
                        room.isClosed = true
                        try? context.save()
                        isRoomFinished = true
                    }
                )
                .transition(.opacity)
            }
        }
        .background(Color("Backgroundcolor").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        // الانتقال التلقائي لشاشة الملخص الختامي وحفظ الذكريات عند انتهاء الروم
        .navigationDestination(isPresented: $isRoomFinished) {
            RoomSummary(room: room)
        }
    }
}

#Preview {
    // 1. إنشاء حاوية بيانات وهمية في الذاكرة المؤقتة فقط للـ Preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    
    // 2. تجهيز بيانات غرفة تجريبية
    let sampleRoom = Room(
        name: "Mission District Mural Hunt",
        code: "JSR-659",
        category: "Creative",
        location: "Outdoor",
        maxPhotos: 9
    )
    
    // 3. تجهيز مستخدم تجريبي وصور داخل الغرفة عشان نشوف الـ ForEach وهي تتكرر حياً!
    let sampleUser = User(name: "Wteen Alghamdy")
    let photo1 = Photo(url: "mock_url_1", room: sampleRoom, user: sampleUser)
    let photo2 = Photo(url: "mock_url_2", room: sampleRoom, user: sampleUser)
    
    // إدخال البيانات في الـ Context المؤقت
    container.mainContext.insert(sampleRoom)
    container.mainContext.insert(sampleUser)
    container.mainContext.insert(photo1)
    container.mainContext.insert(photo2)
    
    return NavigationStack {
        RoomFeed(room: sampleRoom, isHost: true, isShowingFeed: .constant(true))
            .modelContainer(container)
    }
}
