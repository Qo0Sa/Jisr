

//
//  RoomSelectionSheet.swift
//  Jisr
//
//  Created by Wteen on 25/11/1447 AH.
//

import SwiftUI
import SwiftData

struct RoomSelectionSheet: View {
    @Environment(\.modelContext) private var context
    @Binding var isPresented: Bool
    
    @State private var roomName: String = ""
    @State private var selectedCategory: String = "Physical"
    @State private var isOutdoor: Bool = true
    @State private var photoLimit: Int = 3
    
    var onRoomCreated: () -> Void = {}
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text("Create Room")
                        .font(.UbuntuBold(size: 22))
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0)
                }
                .padding(.top, 10)
                
                TextField("Room Name", text: $roomName)
                    .font(.Ubuntu(size: 16))
                    .padding()
                    .frame(height: 54)
                    .background(Color("fieldColor")) // سحب من الـ Assets مباشرة
                    .clipShape(RoundedRectangle(cornerRadius: 99))
                
                HStack(spacing: -10) {
                    CategoryCard(
                        title: "Cognitive",
                        icon: "book.closed.fill",
                        bgColor: Color("cognitiveColor"), // سحب من الـ Assets مباشرة
                        isSelected: selectedCategory == "Cognitive",
                        degree: -12
                    ) { selectedCategory = "Cognitive" }
                    
                    CategoryCard(
                        title: "Physical",
                        icon: "figure.run",
                        bgColor: Color("physicalColor"), // سحب من الـ Assets مباشرة
                        isSelected: selectedCategory == "Physical",
                        degree: 0
                    ) { selectedCategory = "Physical" }
                        .offset(y: -15)
                        .zIndex(selectedCategory == "Physical" ? 1 : 0)
                    
                    CategoryCard(
                        title: "Creative",
                        icon: "paintpalette.fill",
                        bgColor: Color("creativeColor"), // سحب من الـ Assets مباشرة
                        isSelected: selectedCategory == "Creative",
                        degree: 12
                    ) { selectedCategory = "Creative" }
                }
                .padding(.vertical, 25)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activity Place")
                        .font(.UbuntuBold(size: 16))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 0) {
                        Button(action: { isOutdoor = true }) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                Text("out door")
                            }
                            .font(.UbuntuBold(size: 14))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(isOutdoor ? Color("buttonColor") : Color.clear)
                            .foregroundColor(isOutdoor ? .white : .gray)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                        }
                        
                        Button(action: { isOutdoor = false }) {
                            HStack {
                                Image(systemName: "house.fill")
                                Text("in door")
                            }
                            .font(.UbuntuBold(size: 14))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(!isOutdoor ? Color("buttonColor") : Color.clear)
                            .foregroundColor(!isOutdoor ? .white : .gray)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                        }
                    }
                    .padding(4)
                    .frame(height: 48)
                    .background(Color("fieldColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 99))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Photo Limit")
                        .font(.UbuntuBold(size: 16))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 0) {
                        ForEach([3, 5, 8], id: \.self) { limit in
                            Button(action: { photoLimit = limit }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "photo.fill")
                                    Text("\(limit)")
                                }
                                .font(.UbuntuBold(size: 14))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(photoLimit == limit ? Color("buttonColor") : Color.clear)
                                .foregroundColor(photoLimit == limit ? .white : .gray)
                                .clipShape(RoundedRectangle(cornerRadius: 99))
                            }
                        }
                    }
                    .padding(4)
                    .frame(height: 48)
                    .background(Color("fieldColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 99))
                }
                .padding(.bottom, 15)
                
                Button(action: createRoomAction) {
                    Text("Create")
                        .font(.UbuntuBold(size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(roomName.isEmpty ? Color("buttonColor").opacity(0.5) : Color("buttonColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 99))
                }
                .disabled(roomName.isEmpty)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .padding(.horizontal, 24)
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        }
        
        
    }
    
    private func createRoomAction() {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        let p1 = String((0..<3).map { _ in chars.randomElement()! })
        let p2 = String((0..<3).map { _ in chars.randomElement()! })
        let generatedCode = "\(p1)-\(p2)"
        
        let newRoom = Room(
            name: roomName,
            code: generatedCode,
            category: selectedCategory,
            location: isOutdoor ? "Outdoor" : "Indoor",
            maxPhotos: photoLimit
            
        )
        
        context.insert(newRoom)
        try? context.save()
        isPresented = false
        onRoomCreated()
    }
}

struct CategoryCard: View {
    let title: String
    let icon: String
    let bgColor: Color
    let isSelected: Bool
    let degree: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 46, height: 46)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(bgColor)
                }
                Text(title)
                    .font(.UbuntuBold(size: 14))
                    .foregroundColor(.white)
            }
            .frame(width: 102, height: 124)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .rotationEffect(.degrees(degree))
            .shadow(color: isSelected ? bgColor.opacity(0.6) : Color.clear, radius: isSelected ? 15 : 0, x: 0, y: 0)
            .scaleEffect(isSelected ? 1.08 : 0.92)
            .opacity(isSelected ? 1.0 : 0.6)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
    }
}

#Preview {
    RoomSelectionSheet(isPresented: .constant(true))
        .modelContainer(for: [Room.self], inMemory: true)
}
