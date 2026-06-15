//
//  ProfileRoomsTabView.swift
//  Jisr
//

import SwiftUI
import SwiftData

struct ProfileRoomsTabView: View {
    
    let selectedCategory: String
    
    @Query private var allRooms: [Room]
    
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
                    
                    VStack(spacing: -40) {
                        
                        ForEach(Array(filteredRooms.enumerated()),
                                id: \.element.persistentModelID) { index, room in
                            
                            RoomCardView(room: room)
                                .zIndex(Double(filteredRooms.count - index))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color("Backgroundcolor")
            .ignoresSafeArea()
        
        ProfileRoomsTabView(selectedCategory: "All")
    }
}
