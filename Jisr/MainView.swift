//
//  MainView.swift
//  Jisr
//
//  Created by Sarah on 24/11/1447 AH.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Query private var rooms: [Room]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Rooms")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            if rooms.isEmpty {
                Spacer()
                Text("No Rooms Here Yet")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(rooms) { room in
                            RoomCard(room: room)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // زر إضافة غرفة
            Button {
                // هنا نفتح Create Room
            } label: {
                Label("add a room to start", systemImage: "plus")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            }
            .foregroundStyle(.gray)
        }
        .navigationBarBackButtonHidden()
    }
}

struct RoomCard: View {
    let room: Room
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.yellow.opacity(0.4))
                .frame(width: 50, height: 50)
            
            Text(room.name)
                .bold()
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
