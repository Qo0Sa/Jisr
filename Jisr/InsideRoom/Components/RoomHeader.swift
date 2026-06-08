////
////  RoomHeader.swift
////  Jisr
////
////  Created by Wteen Alghamdy on 04/12/1447 AH.
////
//
////
////  RoomHeader.swift
////  Jisr
////
////  Created by Wteen Alghamdy on 01/12/1447 AH.
////
//
//import SwiftUI
//
//struct RoomHeader: View {
//    let currentProgress: Int
//    let maxPhotos: Int
//    let isShowingFeed: Bool
//    let onGalleryToggle: () -> Void
//    
//    // محاكاة لصور الأعضاء المتواجدين في الغرفة حياً (Avatars)
//    let sampleUsers = ["person.fill", "person.fill", "person.fill"]
//    
////    var body: some View {
////        HStack {
////            // ─── اليسار: الأفاتارات المتداخلة للأعضاء ───
////            HStack(spacing: -14) {
////                ForEach(0..<min(sampleUsers.count, 3), id: \.self) { index in
////                    Circle()
////                        .fill(Color.black.opacity(0.08))
////                        .frame(width: 38, height: 38)
////                        .overlay(
////                            Circle()
////                                .stroke(Color.white, lineWidth: 2)
////                        )
////                        .overlay {
////                            Image(systemName: sampleUsers[index])
////                                .font(.system(size: 14))
////                                .foregroundColor(.black.opacity(0.3))
////                        }
////                }
////                
////                // عداد الأشخاص الإضافيين داخل الروم (+3)
////                if sampleUsers.count > 3 {
////                    Text("+\(sampleUsers.count - 3)")
////                        .font(.system(size: 13, weight: .semibold))
////                        .foregroundColor(.white)
////                        .frame(width: 38, height: 38)
////                        .background(Color.black.opacity(0.4))
////                        .clipShape(Circle())
////                        .overlay(
////                            Circle()
////                                .stroke(Color.white, lineWidth: 2)
////                        )
////                }
////            }
////            
////            Spacer()
////            
////            // ─── اليمين: كبسولة الـ Progress وزر التبديل ───
////            HStack(spacing: 12) {
////                // كبسولة العداد المشتركة (6/9)
////                HStack(spacing: 4) {
////                    Text("\(currentProgress)/\(maxPhotos)")
////                        .font(.UbuntuBold(size: 14))
////                        .foregroundColor(.black.opacity(0.7))
////                }
////                .padding(.horizontal, 14)
////                .padding(.vertical, 8)
////                .background(Color("fieldColor"))
////                .clipShape(Capsule())
////                
////                // زر التبديل التفاعلي بين الكاميرا والمعرض الحي
////                Button(action: onGalleryToggle) {
////                    ZStack {
////                        Circle()
////                            .fill(Color.black.opacity(0.75))
////                            .frame(width: 42, height: 42)
////                        
////                        Image(systemName: isShowingFeed ? "camera.fill" : "photo.on.rectangle.angled")
////                            .font(.system(size: 16, weight: .medium))
////                            .foregroundColor(.white)
////                    }
////                }
////            }
////        }
////        .padding(.horizontal, 24)
////        .padding(.vertical, 12)
////        .background(Color("Backgroundcolor").opacity(0.95))
////    }
//    // 1. استقبال موديل الروم الحقيقي المسجل في الكلاود
//        let room: Room
//        
//        // 2. حالة للتحكم بتمدد وانكماش الكبسولة عند الضغط
//        @State private var isExpanded = false
//        
//        // 3. لون الكبسولات الرمادي الدافئ المتناسق مع التصميم
//        let warmGray = Color(red: 0.55, green: 0.53, blue: 0.50)
//        
//        // 4. لوجيك الكلاود: جلب قائمة الحسابات الحقيقية المتواجدة في الغرفة
//        // ⚠️ (استبدلي room.members بالاسم الحقيقي للمصفوفة عندك في موديل Room مثل users أو participants)
//        var cloudMembers: [User] {
//            return room.members ?? []
//        }
//        
//        // 5. لوجيك الكلاود: حساب كم صورة رفع هذا الحساب بالذات داخل هذه الغرفة
//        func getPhotosCount(for user: User) -> Int {
//            let allPhotos = room.photos ?? []
//            return allPhotos.filter { $0.user?.id == user.id }.count
//        }
//}
//
//#Preview {
//    VStack {
//        RoomHeader(currentProgress: 6, maxPhotos: 9, isShowingFeed: false, onGalleryToggle: {})
//        Spacer()
//    }
//    .background(Color("Backgroundcolor").ignoresSafeArea())
//}
//
//  RoomHeader.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 01/12/1447 AH.
//

import SwiftUI
import SwiftData

struct RoomHeader: View {
    let currentProgress: Int
    let maxPhotos: Int
    let isShowingFeed: Bool
    let onGalleryToggle: () -> Void
    let room: Room
    var onBack: (() -> Void)? = nil
    
    // 2. حالة للتحكم بتمدد وانكماش الكبسولة عند الضغط
    @State private var isExpanded = false
    
    // 3. لون الكبسولات الرمادي الدافئ المتناسق مع التصميم
    let warmGray = Color(red: 0.55, green: 0.53, blue: 0.50)
    
    // 4. لوجيك الكلاود: جلب قائمة الحسابات الحقيقية المتواجدة في الغرفة عبر الـ participants
    var cloudMembers: [User] {
        guard let participants = room.participants else { return [] }
        return participants.compactMap { $0.user }
    }
    
    // 5. لوجيك الكلاود: حساب كم صورة رفع هذا الحساب بالذات داخل هذه الغرفة
    func getPhotosCount(for user: User) -> Int {
        let allPhotos = room.photos ?? []
        return allPhotos.filter { $0.user?.id == user.id }.count
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {

            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(warmGray)
                        .clipShape(Circle())
                }
                .buttonStyle(EmptyButtonStyle())
            }

            // كبسولة الأعضاء الحقيقية: عند الضغط عليها تتمدد بأنيميشن مرن
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            }) {
                if !isExpanded {
                    // ─── 1️⃣ الشكل الملموم المتداخل (نفس صورة الفيجما الأولى) ───
                    HStack(spacing: -12) {
                        if cloudMembers.isEmpty {
                            // شكل افتراضي مؤقت في حال لسه البيانات ما حملت من الكلاود
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .foregroundColor(.white.opacity(0.6))
                        } else {
                            // عرض أفاتارات أول 3 حسابات حقيقية دخلت الروم
                            ForEach(0..<min(cloudMembers.count, 3), id: \.self) { index in
                                let user = cloudMembers[index]
                                
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                    .overlay(
                                        Group {
                                            // عرض الصورة الشخصية الحقيقية من الكلاود إذا كانت موجودة، وإلا أول حرف
                                            if let imageData = user.profileImage, let uiImage = UIImage(data: imageData) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .clipShape(Circle())
                                            } else {
                                                Text(String(user.name.prefix(1)).uppercased())
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    )
                            }
                            
                            // حساب باقي الحسابات الحقيقية المتواجدة بالكلاود (+2، +3...)
                            if cloudMembers.count > 3 {
                                Text("+\(cloudMembers.count - 3)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.leading, 14)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .frame(height: 44)
                    .background(warmGray)
                    .clipShape(Capsule())
                    
                } else {
                    // ─── 2️⃣ الشكل المفتوح الأفقي (نفس صورة الفيجما الثانية) ───
                    HStack(spacing: 16) {
                        ForEach(cloudMembers) { user in
                            VStack(spacing: 6) {
                                // أفاتار أو صورة الحساب الحقيقي
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                    .overlay(
                                        Group {
                                            if let imageData = user.profileImage, let uiImage = UIImage(data: imageData) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .clipShape(Circle())
                                            } else {
                                                Text(String(user.name.prefix(1)).uppercased())
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    )
                                
                                // العداد الحي الخاص بكل حساب (كم صورة نزل من الحد الأقصى للروم)
                                Text("\(getPhotosCount(for: user))/\(room.maxPhotos)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(warmGray)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            }
            .buttonStyle(EmptyButtonStyle()) // يمنع تأثير الفلاش الرمادي المزعج عند الضغط
            
            // كبسولة العداد وزر التبديل يمين (تختفي مؤقتاً لما تفتحين الحسابات عشان ما تزدحم الشاشة)
            if !isExpanded {
                Spacer()
                
                HStack(spacing: 10) {
                    Text("\(currentProgress)/\(maxPhotos)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.leading, 12)
                    
                    Button(action: onGalleryToggle) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: isShowingFeed ? "camera.fill" : "photo.on.rectangle.angled")
                                    .foregroundColor(.black)
                                    .font(.system(size: 16))
                            )
                    }
                    .padding(.trailing, 4)
                }
                .frame(height: 44)
                .background(warmGray)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .background(Color.clear)
    }
}

// ستايل الزر لمنع تأثير التحديد ومضات اللون الأزرق
struct EmptyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    let sampleRoom = Room(name: "Test Room", code: "JSR-123", category: "Creative", location: "Outdoor", maxPhotos: 9)
    return RoomHeader(currentProgress: 6, maxPhotos: 9, isShowingFeed: false, onGalleryToggle: {}, room: sampleRoom)
        .modelContainer(container)
        .background(Color.gray)
}
