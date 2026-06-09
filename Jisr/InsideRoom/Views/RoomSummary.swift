//
//  RoomSummary.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//

import SwiftUI
import SwiftData
import Photos

struct RoomSummary: View {
    let room: Room
    @Environment(\.dismiss) private var dismiss
    @Query private var users: [User]

    // All room photos (for the stack display)
    var roomPhotos: [Photo] { (room.photos ?? []).sorted(by: { $0.uploadedAt > $1.uploadedAt }) }

    // Only the current user's photos — these are the only ones that get saved
    var myPhotos: [Photo] {
        guard let me = users.first else { return [] }
        return roomPhotos.filter { $0.user?.id == me.id }
    }

    @State private var isSaving        = false
    @State private var saveSucceeded   = false
    @State private var showPermissionAlert = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Button(action: {
                    dismiss()
                    NotificationCenter.default.post(name: NSNotification.Name("DismissRoomFlow"), object: nil)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()
            Text("Do You Want To Save These Photos?")
                .font(.UbuntuBold(size: 22))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer().frame(height: 40)

            if roomPhotos.isEmpty {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.black.opacity(0.04))
                    .frame(width: 280, height: 340)
                    .overlay { Image(systemName: "photo.on.rectangle.angled").foregroundColor(.black.opacity(0.15)) }
            } else {
                SwipeablePhotoStack(photos: roomPhotos)
            }

            Spacer()

            // MARK: - Save button
            Button(action: saveMyPhotos) {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView().tint(.white)
                        Text("Saving...").font(.UbuntuBold(size: 20))
                    } else if saveSucceeded {
                        Image(systemName: "checkmark").font(.system(size: 18, weight: .bold))
                        Text("Saved!").font(.UbuntuBold(size: 20))
                    } else {
                        Text("Save Photos").font(.UbuntuBold(size: 20))
                        Image(systemName: "square.and.arrow.down").font(.system(size: 18, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    saveSucceeded
                        ? Color.green.opacity(0.75)
                        : Color(red: 0.18, green: 0.18, blue: 0.18)
                )
                .clipShape(RoundedRectangle(cornerRadius: 99))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
            }
            .disabled(isSaving || saveSucceeded)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color("Backgroundcolor").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .alert("Photo Access Needed", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Allow Jisr to save to your Camera Roll in Settings → Privacy → Photos.")
        }
    }

    // MARK: - Save logic

    private func saveMyPhotos() {
        // No personal photos — just go back
        guard !myPhotos.isEmpty else {
            NotificationCenter.default.post(name: NSNotification.Name("DismissRoomFlow"), object: nil)
            return
        }

        isSaving = true

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    performSave()
                default:
                    isSaving = false
                    showPermissionAlert = true
                }
            }
        }
    }

    private func performSave() {
        let images: [UIImage] = myPhotos.compactMap { photo in
            guard let data = photo.imageData else { return nil }
            return UIImage(data: data)
        }

        PHPhotoLibrary.shared().performChanges({
            for image in images {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }) { success, _ in
            DispatchQueue.main.async {
                isSaving = false
                if success {
                    saveSucceeded = true
                    // Brief green flash, then dismiss to main
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        dismiss()
                        NotificationCenter.default.post(name: NSNotification.Name("DismissRoomFlow"), object: nil)
                    }
                } else {
                    // Save failed silently — still go back
                    NotificationCenter.default.post(name: NSNotification.Name("DismissRoomFlow"), object: nil)
                }
            }
        }
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
