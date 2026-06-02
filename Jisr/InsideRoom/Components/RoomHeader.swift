//
//  RoomHeader.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//

//
//  RoomHeader.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 01/12/1447 AH.
//

import SwiftUI

struct RoomHeader: View {
    let currentProgress: Int
    let maxPhotos: Int
    let isShowingFeed: Bool
    let onGalleryToggle: () -> Void
    
    // محاكاة لصور الأعضاء المتواجدين في الغرفة حياً (Avatars)
    let sampleUsers = ["person.fill", "person.fill", "person.fill"]
    
    var body: some View {
        HStack {
            // ─── اليسار: الأفاتارات المتداخلة للأعضاء ───
            HStack(spacing: -14) {
                ForEach(0..<min(sampleUsers.count, 3), id: \.self) { index in
                    Circle()
                        .fill(Color.black.opacity(0.08))
                        .frame(width: 38, height: 38)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .overlay {
                            Image(systemName: sampleUsers[index])
                                .font(.system(size: 14))
                                .foregroundColor(.black.opacity(0.3))
                        }
                }
                
                // عداد الأشخاص الإضافيين داخل الروم (+3)
                if sampleUsers.count > 3 {
                    Text("+\(sampleUsers.count - 3)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
            }
            
            Spacer()
            
            // ─── اليمين: كبسولة الـ Progress وزر التبديل ───
            HStack(spacing: 12) {
                // كبسولة العداد المشتركة (6/9)
                HStack(spacing: 4) {
                    Text("\(currentProgress)/\(maxPhotos)")
                        .font(.UbuntuBold(size: 14))
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color("fieldColor"))
                .clipShape(Capsule())
                
                // زر التبديل التفاعلي بين الكاميرا والمعرض الحي
                Button(action: onGalleryToggle) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.75))
                            .frame(width: 42, height: 42)
                        
                        Image(systemName: isShowingFeed ? "camera.fill" : "photo.on.rectangle.angled")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color("Backgroundcolor").opacity(0.95))
    }
}

#Preview {
    VStack {
        RoomHeader(currentProgress: 6, maxPhotos: 9, isShowingFeed: false, onGalleryToggle: {})
        Spacer()
    }
    .background(Color("Backgroundcolor").ignoresSafeArea())
}
