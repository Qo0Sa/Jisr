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
    @GestureState private var dragOffset: CGFloat = 0

    private let trailingCards = 3

    var body: some View {
        VStack(spacing: 16) {
            GeometryReader { geo in
                let size = geo.size

                ZStack {
                    ForEach(Array(photos.enumerated()), id: \.element.id) { i, photo in
                        PhotoSummaryCard(photo: photo)
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                            .scaleEffect(scaleFor(i))
                            .offset(x: xOffsetFor(i), y: yOffsetFor(i))
                            .rotationEffect(.init(degrees: Double(rotationFor(i))), anchor: .bottom)
                            // live gesture offset + tilt on the front card only
                            .offset(x: currentIndex == i ? dragOffset : 0)
                            .rotationEffect(.init(degrees: Double(rotationForGesture(i))), anchor: .top)
                            // FIXED: zIndex relative to current front so swiped cards drop behind
                            .zIndex(zIndexFor(i))
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: dragOffset == 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, out, _ in
                            out = (value.translation.width / size.width) * (size.width / 1.2)
                        }
                        .onEnded { value in
                            let t = value.translation.width
                            if t > 110, currentIndex > 0 {
                                withAnimation(.easeInOut(duration: 0.25)) { currentIndex -= 1 }
                            } else if t < -110, currentIndex < photos.count - 1 {
                                withAnimation(.easeInOut(duration: 0.25)) { currentIndex += 1 }
                            }
                        }
                )
            }
            .frame(height: 300)
            .padding(.top, 36)       // room for cards peeking above the front card
            .padding(.horizontal, 32)

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

    // MARK: - Per-card transforms (relative to currentIndex)

    /// Signed position: 0 = front, +1 = 1 behind, -1 = already swiped
    private func rel(_ i: Int) -> Int { i - currentIndex }

    /// Current card on top; swiped cards sink to the bottom of the z-stack
    private func zIndexFor(_ i: Int) -> Double {
        let idx = rel(i)
        if idx < 0 { return 0 }                         // already swiped → behind everything
        return Double(photos.count) - Double(idx)        // front = N, 1-behind = N-1, …
    }

    /// Cards behind fan upper-right (like a Polaroid deck); swiped cards stay at 0
    private func xOffsetFor(_ i: Int) -> CGFloat {
        let idx = rel(i)
        guard idx > 0 else { return 0 }
        return CGFloat(min(idx, trailingCards)) * 8
    }

    private func yOffsetFor(_ i: Int) -> CGFloat {
        let idx = rel(i)
        guard idx > 0 else { return 0 }
        return -CGFloat(min(idx, trailingCards)) * 14   // peek above the front card
    }

    /// Scale: front = 1.0, each step behind shrinks by 4%
    private func scaleFor(_ i: Int) -> CGFloat {
        let idx = rel(i)
        guard idx > 0 else { return 1.0 }
        return max(0.88, 1.0 - CGFloat(min(idx, trailingCards)) * 0.04)
    }

    /// Static tilt: front = 0°, each step behind adds 2° clockwise
    private func rotationFor(_ i: Int) -> CGFloat {
        let idx = rel(i)
        guard idx > 0 else { return 0 }
        return CGFloat(min(idx, trailingCards)) * 2
    }

    /// Live tilt as front card is dragged
    private func rotationForGesture(_ i: Int) -> CGFloat {
        guard currentIndex == i else { return 0 }
        return (dragOffset / UIScreen.main.bounds.width) * 30
    }
}

struct PhotoSummaryCard: View {
    let photo: Photo

    var body: some View {
        // Just the photo — no white area below
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.05))
                .aspectRatio(1.0, contentMode: .fit)
                .overlay {
                    if let data = photo.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.black.opacity(0.1))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))

            // Single badge: avatar + name + thought + emoji
            HStack(alignment: .top, spacing: 8) {
                // Avatar
                Circle()
                    .fill(Color.black.opacity(0.15))
                    .frame(width: 28, height: 28)
                    .overlay {
                        if let data = photo.user?.profileImage,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        } else {
                            Text(String((photo.user?.name ?? "?").prefix(1)).uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                // Name on top, thought + emoji below
                VStack(alignment: .leading, spacing: 2) {
                    Text(photo.user?.name ?? "Member")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black.opacity(0.85))
                        .lineLimit(1)

                    HStack(alignment: .top, spacing: 3) {
                        if !photo.thought.isEmpty {
                            Text(photo.thought)
                                .font(.system(size: 11))
                                .foregroundColor(.black.opacity(0.6))
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Text(photo.emoji)
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
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
