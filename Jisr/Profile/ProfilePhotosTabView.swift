



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
    
    @Query private var users: [User]
    @Query private var allPhotos: [Photo]
    
    // 💡 الفلترة المباشرة المعتمدة على المقارنة بالـ selectedCategory وعرض الكل عند اختيار All
    var filteredPhotos: [Photo] {
        guard let currentUser = users.first else { return [] }
        
        let userSpecificPhotos = allPhotos
            .filter { $0.user?.name == currentUser.name }
            .sorted(by: { $0.uploadedAt > $1.uploadedAt })
        
        if selectedCategory == "All" {
            return userSpecificPhotos
        }
        return userSpecificPhotos.filter { $0.room?.category == selectedCategory }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        Group {
            if filteredPhotos.isEmpty {
                VStack(spacing: 16) {
                    Spacer().frame(height: 60)
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
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredPhotos, id: \.persistentModelID) { photo in
                            ZStack(alignment: .bottomLeading) {
                                // Photo image
                                if let data = photo.imageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .aspectRatio(1.0, contentMode: .fit)
                                        .clipped()
                                } else {
                                    Rectangle()
                                        .fill(Color.black.opacity(0.06))
                                        .aspectRatio(1.0, contentMode: .fit)
                                        .overlay {
                                            Image(systemName: "photo.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(.black.opacity(0.15))
                                        }
                                }

                                // Emoji badge in bottom-left corner
                                if !photo.emoji.isEmpty {
                                    Text(photo.emoji)
                                        .font(.system(size: 15))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 4)
                                        .background(.ultraThinMaterial,
                                                    in: RoundedRectangle(cornerRadius: 8))
                                        .padding(7)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color("Backgroundcolor").ignoresSafeArea()
        ProfilePhotosTabView(selectedCategory: "All")
    }
}
