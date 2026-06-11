//
//  RoomHeaderV2.swift
//  Jisr
//

import SwiftUI
import SwiftData

struct RoomHeader: View {
    let room: Room
    let currentProgress: Int
    let maxPhotos: Int
    let isShowingFeed: Bool
    var participants: [[String: Any]] = []   // ✅ من Firestore
    var onGalleryToggle: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil

    @State private var isExpanded = false
    private let warmGray = Color(red: 0.55, green: 0.53, blue: 0.50)

    var body: some View {
        ZStack(alignment: .top) {

            HStack(alignment: .top, spacing: 0) {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(warmGray)
                        .clipShape(Circle())
                }
                .buttonStyle(EmptyButtonStyle())

                Spacer()

                if !isExpanded {
                    HStack(spacing: 10) {
                        Text("\(currentProgress)/\(maxPhotos)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.leading, 12)

                        Button(action: { onGalleryToggle?() }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: isShowingFeed ? "camera.fill" : "photo.on.rectangle.angled")
                                        .foregroundColor(.black)
                                        .font(.system(size: 16))
                                )
                        }
                        .padding(.trailing, 4)
                    }
                    .frame(height: 44)
                    .background(warmGray)
                    .clipShape(Capsule())
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }
            }

            // ✅ الأعضاء من Firestore
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            }) {
                if !isExpanded {
                    HStack(spacing: -12) {
                        if participants.isEmpty {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .foregroundColor(.white.opacity(0.6))
                        } else {
                            ForEach(0..<min(participants.count, 3), id: \.self) { index in
                                let participant = participants[index]
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                    .overlay(
                                        Group {
                                            if let base64 = participant["profileImageBase64"] as? String,
                                               let data = Data(base64Encoded: base64),
                                               let uiImage = UIImage(data: data) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .clipShape(Circle())
                                            } else {
                                                let name = participant["userName"] as? String ?? "?"
                                                Text(String(name.prefix(1)).uppercased())
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    )
                            }
                            if participants.count > 3 {
                                Text("+\(participants.count - 3)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.leading, 14)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .frame(height: 44)
                    .background(warmGray)
                    .clipShape(Capsule())
                } else {
                    HStack(spacing: 16) {
                        ForEach(Array(participants.enumerated()), id: \.offset) { _, participant in
                            let name = participant["userName"] as? String ?? "?"
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                    .overlay(
                                        Group {
                                            if let base64 = participant["profileImageBase64"] as? String,
                                               let data = Data(base64Encoded: base64),
                                               let uiImage = UIImage(data: data) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .clipShape(Circle())
                                            } else {
                                                Text(String(name.prefix(1)).uppercased())
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    )
                                Text(name)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(warmGray)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            }
            .buttonStyle(EmptyButtonStyle())
        }
        .padding(.horizontal, 16)
    }
}

struct EmptyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    let sampleRoom = Room(name: "Test Room", code: "JSR-123", category: "Creative", location: "Outdoor", maxPhotos: 9)
    return RoomHeader(room: sampleRoom, currentProgress: 6, maxPhotos: 9, isShowingFeed: false, onGalleryToggle: {})
        .modelContainer(container)
        .background(Color.gray)
}
