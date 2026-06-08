//
//  RoomSummary.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//

import SwiftUI
import SwiftData

struct RoomSummary: View {
    let room: Room
    @Environment(\.dismiss) private var dismiss

    var roomPhotos: [Photo] { (room.photos ?? []).sorted(by: { $0.uploadedAt > $1.uploadedAt }) }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header — chevron goes straight to main page
            HStack {
                Button(action: {
                    NotificationCenter.default.post(name: NSNotification.Name("DismissRoomFlow"), object: nil)
                    dismiss()
                }) {
                    Image(systemName: "chevron.left").font(.system(size: 22, weight: .bold)).foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()
            Text("Do You Want To Save These Photos?").font(.UbuntuBold(size: 22)).foregroundColor(.black).multilineTextAlignment(.center).padding(.horizontal, 32)
            Spacer().frame(height: 40)

            if roomPhotos.isEmpty {
                RoundedRectangle(cornerRadius: 28).fill(Color.black.opacity(0.04)).frame(width: 280, height: 340)
                    .overlay { Image(systemName: "photo.on.rectangle.angled").foregroundColor(.black.opacity(0.15)) }
            } else {
                SwipeablePhotoStack(photos: roomPhotos)
            }

            Spacer()

            Button(action: {
                NotificationCenter.default.post(name: NSNotification.Name("DismissRoomFlow"), object: nil)
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Text("Save Photos").font(.UbuntuBold(size: 20))
                    Image(systemName: "square.and.arrow.down").font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 58).background(Color(red: 0.18, green: 0.18, blue: 0.18)).clipShape(RoundedRectangle(cornerRadius: 99)).shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
            }
            .padding(.horizontal, 24).padding(.bottom, 24)
        }
        .background(Color("Backgroundcolor").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    let sampleRoom = Room(name: "Mission District Mural Hunt", code: "JSR-99X", category: "Creative", location: "Outdoor", maxPhotos: 9)
    let sampleUser = User(name: "Wteen")
    container.mainContext.insert(sampleRoom)
    container.mainContext.insert(sampleUser)
    return RoomSummary(room: sampleRoom)
        .modelContainer(container)
}
