//
//  Cameraview.swift
//  Jisr
//
//  Created by Sarah Alnasser on 08/06/2026.
//  Replaces RoomContainer + RoomCamera
//

import SwiftUI
import AVFoundation
import Combine
import SwiftData

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

        // Start on ultra-wide (.5x) — avoids a setZoom reconfiguration on launch
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
            // .5x requires the physical ultra-wide lens; 1x/2x use the wide lens
            let targetType: AVCaptureDevice.DeviceType = scale == ".5x"
                ? .builtInUltraWideCamera
                : .builtInWideAngleCamera
            let zoomFactor: CGFloat = scale == "2x" ? 2.0 : 1.0

            guard let device = AVCaptureDevice.default(targetType, for: .video, position: .back) else { return }

            // Only reconfigure session if we're actually switching lenses
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

            // Apply digital zoom for 2x (no-op for .5x / 1x)
            try? device.lockForConfiguration()
            device.videoZoomFactor = max(device.minAvailableVideoZoomFactor,
                                         min(zoomFactor, device.maxAvailableVideoZoomFactor))
            device.unlockForConfiguration()
        }
    }

    func switchCamera() {
        queue.async {
            self.session.beginConfiguration()
            // Read position BEFORE removing inputs
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
            // Store the full-frame image — PhotoBackground uses cropToViewfinder
            // for the live preview, and onSave uses it again for the stored copy.
            DispatchQueue.main.async { self.capturedPhoto = image }
        }
    }
}

// MARK: - Main Camera View (replaces RoomContainer + RoomCamera)

struct CameraView: View {
    let room: Room
    let isHost: Bool

    @StateObject private var camera = CameraSession()
    @State private var isFlashOn = false
    @State private var zoomScale = ".5x"
    @State private var isShowingFeed = false
    @State private var isShowingMaxPhotosPopup = false

    @Environment(\.modelContext) private var context
    @Query private var users: [User]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if isShowingFeed {
                RoomFeed(room: room, isHost: isHost, isShowingFeed: $isShowingFeed)
            } else if let capturedPhoto = camera.capturedPhoto {
                PhotoPreviewView(
                    photo: capturedPhoto,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            camera.capturedPhoto = nil
                        }
                    },
                    onSave: { thought, emoji in
                        // Crop to exactly what the viewfinder showed before saving
                        let screenSize = UIScreen.main.bounds.size
                        let finalImage = cropToViewfinder(image: capturedPhoto, screenSize: screenSize)
                        guard let imageData = finalImage.jpegData(compressionQuality: 0.8) else { return }
                        guard let currentUser = users.first else {
                            print("No user found")
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
                        do {
                            try context.save()
                        } catch {
                            print("Save failed: \(error)")
                        }
                        
                        Task {
                            await CloudKitManager.shared.uploadPhoto(
                                roomCode: room.code,
                                imageData: imageData,
                                thought: thought,
                                emoji: emoji,
                                userName: currentUser.name,
                                profileImage: currentUser.profileImage
                            )
                        }
                        
                        withAnimation(.easeInOut(duration: 0.25)) {
                            camera.capturedPhoto = nil
                            isShowingFeed = true
                        }
                    }
                    
                )
            } else {
                cameraBody
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        // Only start the session when we're actually on the live viewfinder.
        .onAppear {
            if !isShowingFeed && camera.capturedPhoto == nil {
                camera.start()
            }
        }
        .onDisappear { camera.stop() }
        // Switching TO the feed → stop session; returning from feed → restart it.
        .onChange(of: isShowingFeed) { _, showingFeed in
            if showingFeed {
                camera.stop()
            } else if camera.capturedPhoto == nil {
                camera.start()
            }
        }
        // Photo captured → stop session; photo dismissed/saved → restart it.
        .onChange(of: camera.capturedPhoto) { _, photo in
            if photo != nil {
                camera.stop()
            } else if !isShowingFeed {
                camera.start()
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
                // Full-screen blurred camera feed with clear viewfinder hole
                BlurredCameraView(session: camera.session, viewfinderRect: viewfinderRect)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with real room members data
                    RoomHeader(
                        room: room,
                        currentProgress: room.photos?.count ?? 0,
                        maxPhotos: room.maxPhotos,
                        isShowingFeed: isShowingFeed,
                        onGalleryToggle: {
                            withAnimation(.easeInOut(duration: 0.25)) { isShowingFeed = true }
                        },
                        onBack: { dismiss() }
                    )
                    .padding(.top, 62)

                    // Prompt card with real room mission
                    VStack(alignment: .leading, spacing: 6) {
//                        Text(room.missionTitle.isEmpty ? "Today's Mission" : room.missionTitle)
                        Text((room.missionTitle ?? "").isEmpty
                             ? "Today's Mission"
                             : room.missionTitle ?? "")
                        
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("buttonColor"))

//                        Text(room.missionDescription.isEmpty ? "Start capturing moments." : room.missionDescription)
                        Text((room.missionDescription ?? "").isEmpty
                             ? "Start capturing moments."
                             : room.missionDescription ?? "")
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

                    // Bottom controls
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
                            let currentCount = room.photos?.count ?? 0
                            guard currentCount < room.maxPhotos else {
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

                // Max photos popup
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

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    let sampleRoom = Room(
        name: "Mission District Mural Hunt",
        code: "JSR-777",
        category: "Creative",
        location: "Outdoor",
        maxPhotos: 9
    )
    let sampleUser = User(name: "Sara")
    container.mainContext.insert(sampleRoom)
    container.mainContext.insert(sampleUser)
    return NavigationStack {
        CameraView(room: sampleRoom, isHost: true)
            .modelContainer(container)
    }
}
