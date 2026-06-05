
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
    @Query private var allRooms: [Room]
    
    // 💡 جلب الرومات التاريخية المغلقة والتبديل المباشر بناءً على الـ selectedCategory
    var filteredRooms: [Room] {
        let closedRooms = allRooms.filter { $0.isClosed }
        
        if selectedCategory == "All" {
            return closedRooms
        }
        return closedRooms.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        Group {
            if filteredRooms.isEmpty {
                VStack(spacing: 16) {
                    Spacer().frame(height: 60)
                    Image(systemName: "archivebox.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.black.opacity(0.15))
                    
                    VStack(spacing: 6) {
                        Text("No history yet")
                            .font(.UbuntuBold(size: 18))
                            .foregroundColor(.black.opacity(0.6))
                        Text("Your completed rooms and interactions\nwill appear here.")
                            .font(.Ubuntu(size: 14))
                            .foregroundColor(.black.opacity(0.4))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: -42) {
                        // 💡 استخدام الـ persistentModelID كمعرّف ثابت لحفظ استقرار الـ ForEach ومنع الـ Conflicts
                        ForEach(Array(filteredRooms.enumerated()), id: \.element.persistentModelID) { index, room in
                            let cardColor = room.category == "Cognitive" ? Color("cognitiveColor") : (room.category == "Creative" ? Color("creativeColor") : Color("physicalColor"))
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(cardColor)
                                    .frame(height: 150)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 28)
                                            .strokeBorder(style: StrokeStyle(lineWidth: 2.5, dash: [10, 6]))
                                            .foregroundColor(.black.opacity(0.5))
                                    }
                                
                                HStack(alignment: .center) {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(Color.white.opacity(0.25))
                                            .frame(width: 38, height: 38)
                                            .overlay {
                                                Image(systemName: "person.fill")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 16))
                                            }
                                        Text(room.name)
                                            .font(.UbuntuBold(size: 18))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                }
                                .padding(20)
                            }
                            .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
                            .rotationEffect(.degrees(index % 2 == 0 ? -3 : 3)) // وزنية تأثير الحواف المتأرجحة لفيجما
                            .zIndex(Double(filteredRooms.count - index))
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color("Backgroundcolor").ignoresSafeArea()
        ProfileRoomsTabView(selectedCategory: "All")
    }
}
