//
//  SwipeablePhotoStack.swift
//  Jisr
//
//  Created by Sarah Alnasser on 09/06/2026.
//

import SwiftUI
import SwiftData

struct SwipeablePhotoStack: View {
    let photos: [Photo]
    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0

    private let swipeThreshold: CGFloat = 70

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background cards — stacked behind, slightly smaller and offset up
                ForEach((1...min(2, max(1, photos.count - currentIndex - 1))).reversed(), id: \.self) { stackPos in
                    if currentIndex + stackPos < photos.count {
                        PhotoSummaryCard(photo: photos[currentIndex + stackPos])
                            .scaleEffect(1.0 - CGFloat(stackPos) * 0.05)
                            .offset(y: -CGFloat(stackPos) * 18)
                            .zIndex(Double(5 - stackPos))
                    }
                }

                // Front card — draggable
                PhotoSummaryCard(photo: photos[currentIndex])
                    .offset(x: dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset) * 0.02), anchor: .bottom)
                    .zIndex(10)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    if value.translation.width < -swipeThreshold, currentIndex < photos.count - 1 {
                                        currentIndex += 1
                                    } else if value.translation.width > swipeThreshold, currentIndex > 0 {
                                        currentIndex -= 1
                                    }
                                    dragOffset = 0
                                }
                            }
                    )
            }
            .frame(height: 380)
            .padding(.top, 44)        // room for background cards peeking above
            .padding(.horizontal, 24)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentIndex)

            // Page dots
            HStack(spacing: 6) {
                ForEach(0..<photos.count, id: \.self) { i in
                    Circle()
                        .fill(i == currentIndex ? Color.black.opacity(0.6) : Color.black.opacity(0.15))
                        .frame(width: i == currentIndex ? 8 : 6, height: i == currentIndex ? 8 : 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                }
            }
        }
    }
}

struct PhotoSummaryCard: View {
    let photo: Photo

    var body: some View {
        VStack(spacing: 0) {
            // Photo area with user badge overlaid
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.04))
                    .aspectRatio(1.0, contentMode: .fit)
                    .overlay {
                        if let data = photo.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.black.opacity(0.1))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                // User avatar + name
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 36, height: 36)
                        .overlay {
                            if let data = photo.user?.profileImage,
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                            } else {
                                Text(String((photo.user?.name ?? "M").prefix(1)).uppercased())
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    Text(photo.user?.name ?? "Member")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black.opacity(0.8))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(6)
            }

            // Thought + emoji row
            HStack(alignment: .top, spacing: 8) {
                if !photo.thought.isEmpty {
                    Text(photo.thought)
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.6))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer(minLength: 0)
                Text(photo.emoji)
                    .font(.system(size: 22))
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.08), radius: 6, x:0, y: 0)
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    let ctx = container.mainContext

    let room = Room(name: "Golden Hour", code: "JSR-001", category: "Creative", location: "Outdoor", maxPhotos: 9)
    let sara = User(name: "Sara")
    let wteen = User(name: "Wteen")
    let ahmed = User(name: "Ahmed")
    let sampleImage = UIImage(systemName: "mountain.2.fill")?
        .withTintColor(.systemTeal, renderingMode: .alwaysOriginal)
        .jpegData(compressionQuality: 0.8)

    let p1 = Photo(imageData: sampleImage, thought: "The light was absolutely perfect at this moment", emoji: "🤩", room: room, user: sara)
    let p2 = Photo(imageData: sampleImage, thought: "Couldn't believe how quiet it was", emoji: "😊", room: room, user: wteen)
    let p3 = Photo(imageData: sampleImage, thought: "Worth waking up early for", emoji: "😎", room: room, user: ahmed)
    let p4 = Photo(imageData: sampleImage, thought: "aaaaaaaaaaaaa", emoji: "😆", room: room, user: sara)

    let _ = {
        ctx.insert(room); ctx.insert(sara); ctx.insert(wteen); ctx.insert(ahmed)
        ctx.insert(p1); ctx.insert(p2); ctx.insert(p3); ctx.insert(p4)
    }()

    ZStack {
        Color("Backgroundcolor").ignoresSafeArea()
        SwipeablePhotoStack(photos: [p1, p2, p3, p4])
    }
    .modelContainer(container)
}
