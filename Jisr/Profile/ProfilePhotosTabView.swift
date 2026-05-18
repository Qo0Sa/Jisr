




//
//  ProfilePhotosTabView.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 01/12/1447 AH.
//

import SwiftUI
import SwiftData

struct ProfilePhotosTabView: View {
    let selectedCategory: String
    
    // جلب الصور الفعلية من SwiftData لفحص ما إذا كان المستخدم جديداً
    @Query private var allPhotos: [Photo]
    
    // تصفية الصور بناءً على الكاتيجوري المحدد
    var filteredPhotos: [Photo] {
        if selectedCategory == "All" {
            return allPhotos
        }
        return allPhotos.filter { $0.room?.category == selectedCategory }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        Group {
            if filteredPhotos.isEmpty {
                // MARK: - الـ Empty State للمستخدم الجديد (Photos)
                VStack(spacing: 16) {
                    Spacer().frame(height: 60)
                    
                    // أيقونة البوم أو كاميرا بشكل دافئ
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 56))
                        .foregroundColor(.black.opacity(0.15))
                    
                    VStack(spacing: 6) {
                        Text("No photos captured yet")
                            .font(.UbuntuBold(size: 18))
                            .foregroundColor(.black.opacity(0.6))
                        
                        Text("Every moment you document inside a room\nwill appear here.")
                            .font(.Ubuntu(size: 14))
                            .foregroundColor(.black.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            } else {
                // MARK: - شبكة الصور المعتادة مع ميزة التاريخ المثبت (Sticky Headers)
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12, pinnedViews: [.sectionHeaders]) {
                        // هنا يتم تقسيم الصور الفعلية بناءً على تواريخها
                        // (تم الإبقاء على الهيكل لتنظيم الكود مستقبلاً عند ربطه بالـ Data)
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color("Backgroundcolor").ignoresSafeArea()
        ProfilePhotosTabView(selectedCategory: "Creative")
    }
}
