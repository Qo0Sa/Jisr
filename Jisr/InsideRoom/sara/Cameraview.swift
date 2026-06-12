//
//  Cameraview.swift
//  Jisr
//
//  Created by Sarah Alnasser on 08/06/2026.
//

import SwiftUI
import AVFoundation
import Combine
import SwiftData
import FirebaseFirestore

// MARK: - Camera Session Manager

class CameraSession: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "camera.session.queue", qos: .userInteractive)
    private var currentDevice: AVCaptureDevice?
    private let photoOutput = AVCapturePhotoOutput()
    @Published var capturedPhoto: UIImage?

    override init() {
        super.init()
        session.sessionPreset = .photo

        let backDevice = [
            AVCaptureDevice.DeviceType.builtInUltraWideCamera,
            .builtInWideAngleCamera
        ]
        .compactMap { AVCaptureDevice.default($0, for: .video, position: .back) }
        .first

        guard
            let device = backDevice,
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { return }

        session.addInput(input)
        currentDevice = device

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
    }

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { self.startSession() }
            }
        default:
            break
        }
    }

    private func startSession() {
        queue.async {
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    func stop() {
        queue.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    func toggleFlash(turnOn: Bool) {
        guard let device = currentDevice, device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = turnOn ? .on : .off
        device.unlockForConfiguration()
    }

    func setZoom(scale: String) {
        queue.async {
            let targetType: AVCaptureDevice.DeviceType = scale == ".5x"
                ? .builtInUltraWideCamera
                : .builtInWideAngleCamera
            let zoomFactor: CGFloat = scale == "2x" ? 2.0 : 1.0

            guard let device = AVCaptureDevice.default(targetType, for: .video, position: .back) else { return }

            if self.currentDevice != device {
                guard let input = try? AVCaptureDeviceInput(device: device) else { return }
                self.session.beginConfiguration()
                self.session.inputs
                    .compactMap { $0 as? AVCaptureDeviceInput }
                    .filter { $0.device.position == .back }
                    .forEach { self.session.removeInput($0) }
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    self.currentDevice = device
                }
                self.session.commitConfiguration()
            }

            try? device.lockForConfiguration()
            device.videoZoomFactor = max(device.minAvailableVideoZoomFactor,
                                         min(zoomFactor, device.maxAvailableVideoZoomFactor))
            device.unlockForConfiguration()
        }
    }

    func switchCamera() {
        queue.async {
            self.session.beginConfiguration()
            let current = (self.session.inputs.first as? AVCaptureDeviceInput)?.device.position ?? .back
            self.session.inputs.forEach { self.session.removeInput($0) }
            let next: AVCaptureDevice.Position = current == .back ? .front : .back
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: next),
               let input = try? AVCaptureDeviceInput(device: device),
               self.session.canAddInput(input) {
                self.session.addInput(input)
                self.currentDevice = device
            }
            self.session.commitConfiguration()
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraSession: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.capturedPhoto = image }
        }
    }
}

// MARK: - Main Camera View

struct CameraView: View {
    let room: Room
    let isHost: Bool

    @StateObject private var camera = CameraSession()
    @State private var isFlashOn = false
    @State private var zoomScale = "1x"
    @State private var isShowingFeed = false
    @State private var isShowingMaxPhotosPopup = false
    @State private var isSavingPhoto = false

    // ✅ الصور
    @State private var photos: [[String: Any]] = []
    @State private var photosListener: ListenerRegistration? = nil

    // ✅ المشاركين من Firestore
    @State private var participants: [[String: Any]] = []
    @State private var participantsListener: ListenerRegistration? = nil
    @State private var roomListener: ListenerRegistration? = nil
    @State private var isRoomFinished = false

    @Environment(\.modelContext) private var context
    @Query private var users: [User]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if isShowingFeed {
                RoomFeed(room: room, isHost: isHost, isShowingFeed: $isShowingFeed, photos: photos)
            } else if let capturedPhoto = camera.capturedPhoto {
                PhotoPreviewView(
                    photo: capturedPhoto,
                    onDismiss: {
                        guard !isSavingPhoto else { return }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            camera.capturedPhoto = nil
                        }
                    },
                    onSave: { thought, emoji in
                        guard !isSavingPhoto else { return }
                        guard let currentUser = users.first else { return }

                        isSavingPhoto = true
                        let screenSize = UIScreen.main.bounds.size
                        let profileImageData = currentUser.profileImage
                        let userName = currentUser.name
                        let roomCode = room.code

                        DispatchQueue.global(qos: .userInitiated).async {
                            let finalImage = cropToViewfinder(image: capturedPhoto, screenSize: screenSize)
                            let resized = resizeImage(finalImage, maxSize: 800)
                            let imageData = resized.jpegData(compressionQuality: 0.5)

                            let compressedProfile: Data?
                            if let profileImageData,
                               let ui = UIImage(data: profileImageData) {
                                let resizedProfile = resizeImage(ui, maxSize: 100)
                                compressedProfile = resizedProfile.jpegData(compressionQuality: 0.5)
                            } else {
                                compressedProfile = nil
                            }

                            DispatchQueue.main.async {
                                guard let imageData else {
                                    isSavingPhoto = false
                                    return
                                }

                                let newPhoto = Photo(
                                    imageData: imageData,
                                    thought: thought,
                                    emoji: emoji,
                                    room: room,
                                    user: currentUser
                                )
                                context.insert(newPhoto)
                                try? context.save()

                                withAnimation(.easeInOut(duration: 0.25)) {
                                    camera.capturedPhoto = nil
                                    isShowingFeed = true
                                }
                                isSavingPhoto = false

                                Task {
                                    await CloudKitManager.shared.uploadPhoto(
                                        roomCode: roomCode,
                                        imageData: imageData,
                                        thought: thought,
                                        emoji: emoji,
                                        userName: userName,
                                        profileImage: compressedProfile
                                    )
                                }
                            }
                        }
                    },
                    isSaving: isSavingPhoto
                )
            } else {
                cameraBody
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $isRoomFinished) {
            RoomSummary(room: room)
        }
        .onAppear {
            if !isShowingFeed && camera.capturedPhoto == nil {
                camera.start()
            }

            // ✅ listener للصور
            photosListener?.remove()
            photosListener = Firestore.firestore()
                .collection("photos")
                .whereField("roomCode", isEqualTo: room.code)
                .addSnapshotListener { snapshot, error in
                    if let error {
                        print("❌ photos listener: \(error)")
                        return
                    }
                    photos = (snapshot?.documents.map { $0.data() } ?? [])
                        .sorted {
                            let lhs = ($0["uploadedAt"] as? Timestamp)?.dateValue() ?? .distantPast
                            let rhs = ($1["uploadedAt"] as? Timestamp)?.dateValue() ?? .distantPast
                            return lhs > rhs
                        }
                }

            // ✅ listener للمشاركين
            participantsListener?.remove()
            participantsListener = CloudKitManager.shared.listenToParticipants(roomCode: room.code) { updated in
                participants = updated
            }

            if !isHost {
                roomListener?.remove()
                roomListener = CloudKitManager.shared.listenToRoom(roomCode: room.code) { data in
                    guard (data["isClosed"] as? Bool) == true else { return }
                    room.isClosed = true
                    try? context.save()
                    camera.capturedPhoto = nil
                    isShowingFeed = false
                    isRoomFinished = true
                }
            }
        }
        .onDisappear {
            camera.stop()
            photosListener?.remove()
            photosListener = nil
            participantsListener?.remove()
            participantsListener = nil
            roomListener?.remove()
            roomListener = nil
        }
        .onChange(of: isShowingFeed) { _, showingFeed in
            if showingFeed {
                camera.stop()
            } else if camera.capturedPhoto == nil {
                camera.start()
            }
        }
        .onChange(of: camera.capturedPhoto) { _, photo in
            if photo != nil {
                camera.stop()
            } else if !isShowingFeed {
                camera.start()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissRoomFlow"))) { _ in
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: NSNotification.Name("DismissRoomFlow"), object: nil)
            }
        }
    }

    @ViewBuilder
    private var cameraBody: some View {
        GeometryReader { geo in
            let viewfinderWidth = geo.size.width - 48
            let viewfinderX: CGFloat = 24
            let viewfinderY = (geo.size.height - viewfinderWidth) / 2
            let viewfinderRect = CGRect(x: viewfinderX, y: viewfinderY,
                                        width: viewfinderWidth, height: viewfinderWidth)

            ZStack {
                BlurredCameraView(session: camera.session, viewfinderRect: viewfinderRect)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    RoomHeader(
                        room: room,
                        // ✅ الجديد — عدد صور اليوزر الحالي بس
                        currentProgress: photos.filter {
                            ($0["userID"] as? String) == CloudKitManager.shared.currentUserID
                        }.count,                        maxPhotos: room.maxPhotos,
                        isShowingFeed: isShowingFeed,
                        participants: participants,
                        onGalleryToggle: {
                            withAnimation(.easeInOut(duration: 0.25)) { isShowingFeed = true }
                        },
                        onBack: {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("DismissRoomFlow"),
                                object: nil
                            )
                        }
                    )
                    .padding(.top, 62)

                    VStack(alignment: .leading, spacing: 6) {
                        Text((room.missionTitle ?? "").isEmpty ? "Today's Mission" : room.missionTitle ?? "")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("buttonColor"))

                        Text((room.missionDescription ?? "").isEmpty ? "Start capturing moments." : room.missionDescription ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(Color("buttonColor").opacity(0.6))
                            .lineSpacing(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color("Backgroundcolor"), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color("fieldColor"), in: RoundedRectangle(cornerRadius: 16))
                    .compositingGroup()
                    .shadow(color: Color("buttonColor").opacity(0.9), radius: 0, x: 0, y: 2)
                    .environment(\.colorScheme, .light)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                    Spacer()

                    VStack(spacing: 24) {
                        HStack(spacing: 40) {
                            Button(action: {
                                isFlashOn.toggle()
                                camera.toggleFlash(turnOn: isFlashOn)
                            }) {
                                Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(isFlashOn ? .yellow : .black.opacity(0.6))
                                    .frame(width: 44, height: 44)
                                    .background(Color("fieldColor"))
                                    .clipShape(Circle())
                            }

                            HStack(spacing: 12) {
                                ForEach([".5x", "1x", "2x"], id: \.self) { scale in
                                    Text(scale)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(zoomScale == scale ? .white : .black.opacity(0.5))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(zoomScale == scale ? Color.black.opacity(0.7) : Color.clear)
                                        .clipShape(Capsule())
                                        .onTapGesture {
                                            zoomScale = scale
                                            camera.setZoom(scale: scale)
                                        }
                                }
                            }
                            .padding(4)
                            .background(Color("fieldColor"))
                            .clipShape(Capsule())

                            Button(action: { camera.switchCamera() }) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.black.opacity(0.6))
                                    .frame(width: 44, height: 44)
                                    .background(Color("fieldColor"))
                                    .clipShape(Circle())
                            }
                        }

                        Button(action: {
                            // ✅ الجديد
                            let currentCount = photos.filter {
                                ($0["userID"] as? String) == CloudKitManager.shared.currentUserID
                            }.count
                            guard currentCount < room.maxPhotos else  {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isShowingMaxPhotosPopup = true
                                }
                                return
                            }
                            camera.capturePhoto()
                            if isFlashOn {
                                isFlashOn = false
                                camera.toggleFlash(turnOn: false)
                            }
                        }) {
                            Circle()
                                .stroke(Color.black.opacity(0.15), lineWidth: 5)
                                .frame(width: 84, height: 84)
                                .overlay(
                                    Circle()
                                        .fill(Color(red: 0.18, green: 0.18, blue: 0.18))
                                        .frame(width: 68, height: 68)
                                )
                        }
                        .padding(.bottom, 84)
                    }
                }

                if isShowingMaxPhotosPopup {
                    MaxPhotosPopup(
                        isPresented: $isShowingMaxPhotosPopup,
                        maxPhotos: room.maxPhotos
                    )
                    .transition(.opacity)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Resize Helper
func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
    let size = image.size
    let ratio = min(maxSize / size.width, maxSize / size.height)
    guard ratio < 1 else { return image }
    let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: newSize))
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    let sampleRoom = Room(name: "Mission District Mural Hunt", code: "JSR-777", category: "Creative", location: "Outdoor", maxPhotos: 9)
    let sampleUser = User(name: "Sara")
    container.mainContext.insert(sampleRoom)
    container.mainContext.insert(sampleUser)
    return NavigationStack {
        CameraView(room: sampleRoom, isHost: true)
            .modelContainer(container)
    }
}
