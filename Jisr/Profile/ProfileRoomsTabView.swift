
//
//  ProfileRoomsTabView.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 01/12/1447 AH.
//

import SwiftUI
import SwiftData

struct ProfileRoomsTabView: View {
    let selectedCategory: String
    
    // جلب الغرف التاريخية من SwiftData لفحصها
    @Query private var allRooms: [Room]
    
    // تصفية الغرف حسب الفئة
    var filteredRooms: [Room] {
        if selectedCategory == "All" {
            return allRooms
        }
        return allRooms.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        Group {
            if filteredRooms.isEmpty {
                // MARK: - الـ Empty State للمستخدم الجديد (Rooms)
                VStack(spacing: 16) {
                    Spacer().frame(height: 60)
                    
                    // أيقونة تدل على الأرشيف أو الغرف التاريخية المغلقة
                    Image(systemName: "archivebox.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.black.opacity(0.15))
                    
                    VStack(spacing: 6) {
                        Text("No active history yet")
                            .font(.UbuntuBold(size: 18))
                            .foregroundColor(.black.opacity(0.6))
                        
                        Text("Your completed rooms and interactions\nwill appear here.")
                            .font(.Ubuntu(size: 14))
                            .foregroundColor(.black.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            } else {
                // MARK: - مكدس الرومات المتراكمة المائلة (Perspective Stack)
                VStack(spacing: -45) {
                    ForEach(filteredRooms, id: \.id) { room in
                        // كود الروم المائل المتفاعل التابع لكم
                    }
                }
                .padding(.top, 40)
            }
        }
    }
}

#Preview {
    ZStack {
        Color("Backgroundcolor").ignoresSafeArea()
        ProfileRoomsTabView(selectedCategory: "Creative")
    }
}
