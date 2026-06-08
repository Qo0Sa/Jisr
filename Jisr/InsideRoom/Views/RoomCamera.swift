//
//  RoomCamera.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//

//
//  RoomCamera.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 01/12/1447 AH.
//

import SwiftUI
import SwiftData
import AVFoundation
import Combine


struct RoomCamera: View {
    let room: Room
    @Binding var isShowingFeed: Bool
    let onPhotoCaptured: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isFlashOn = false
    @State private var zoomScale: String = "1x"
    @StateObject private var camera = CameraManager()

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()

            Color("Backgroundcolor")
                .opacity(0.82)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                RoomHeader(
                    currentProgress: room.photos?.count ?? 0,
                    maxPhotos: room.maxPhotos,
                    isShowingFeed: isShowingFeed,
                    onGalleryToggle: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isShowingFeed = true
                        }
                    },
                    room: room,
                    onBack: { dismiss() }
                )

                // Prompt card
                VStack(alignment: .leading, spacing: 6) {
                    Text(room.missionTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("buttonColor"))

                    Text(room.missionDescription)
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
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Spacer()

                // Camera preview — contained rectangle
                CameraPreview(session: camera.session)
                    .aspectRatio(0.88, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 36))
                    .padding(.horizontal, 24)

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
                                    .font(.UbuntuBold(size: 13))
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

                    Button(action: { camera.capturePhoto() }) {
                        Circle()
                            .stroke(Color.black.opacity(0.15), lineWidth: 5)
                            .frame(width: 84, height: 84)
                            .overlay(
                                Circle()
                                    .fill(Color(red: 0.18, green: 0.18, blue: 0.18))
                                    .frame(width: 68, height: 68)
                            )
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            camera.startSession()
            camera.onPhotoCaptured = { image in
                onPhotoCaptured(image)
            }
        }
        .onDisappear {
            camera.stopSession()
        }
    }
}


final class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    var onPhotoCaptured: ((UIImage) -> Void)?
    private var currentInput: AVCaptureDeviceInput?
    private var currentPosition: AVCaptureDevice.Position = .back
    private var isConfigured = false

//    override init() {
//        super.init()
//        configure()
//    }
    override init() {
        super.init()

        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {

        case .authorized:
            configure()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.configure()
                    }
                }
            }

        default:
            print("❌ Camera permission denied")
        }
    }
    
    private func configure() {

        print("✅ CONFIGURE CALLED")

        session.beginConfiguration()

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            print("❌ NO CAMERA DEVICE")
            return
        }

        guard let input = try? AVCaptureDeviceInput(device: device) else {
            print("❌ FAILED INPUT")
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
            currentInput = input
            print("✅ INPUT ADDED")
        }

        if session.canAddOutput(output) {
            session.addOutput(output)
            print("✅ OUTPUT ADDED")
        }

        session.commitConfiguration()
        isConfigured = true
        
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.session.startRunning()
//
//            DispatchQueue.main.async {
//                self.objectWillChange.send()
//            }
//
//            print("✅ SESSION RUNNING = \(self.session.isRunning)")
//        }
        
    }
    
    func switchCamera() {
            session.beginConfiguration()
            
            if let currentInput = currentInput {
                session.removeInput(currentInput)
            }
            
            currentPosition = (currentPosition == .back) ? .front : .back
            
            guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentPosition) else { return }
            guard let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return }
            
            if session.canAddInput(newInput) {
                session.addInput(newInput)
                currentInput = newInput
            } else {
                // إعادة العدسة الخلفية كحماية في حال تعطل الأمامية
                if let currentInput = currentInput { session.addInput(currentInput) }
            }
            
            session.commitConfiguration()
        }
        
        // 💡 وظيفة التحكم بكشاف الهاتف الفعلي أثناء التصوير
        func toggleFlash(turnOn: Bool) {
            guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
            do {
                try device.lockForConfiguration()
                device.torchMode = turnOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("❌ Torch alignment error: \(error.localizedDescription)")
            }
        }
        
        func setZoom(scale: String) {
            switch scale {
            case ".5x":
                // Ultra-wide is a separate physical lens — must swap the camera input
                switchToLens(type: .builtInUltraWideCamera, zoomFactor: 1.0)
            case "2x":
                switchToLens(type: .builtInWideAngleCamera, zoomFactor: 2.0)
            default: // "1x"
                switchToLens(type: .builtInWideAngleCamera, zoomFactor: 1.0)
            }
        }

        private func switchToLens(type: AVCaptureDevice.DeviceType, zoomFactor: CGFloat) {
            guard let device = AVCaptureDevice.default(type, for: .video, position: currentPosition) else { return }
            guard let newInput = try? AVCaptureDeviceInput(device: device) else { return }

            session.beginConfiguration()
            if let currentInput { session.removeInput(currentInput) }
            if session.canAddInput(newInput) {
                session.addInput(newInput)
                currentInput = newInput
            }
            session.commitConfiguration()

            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = max(device.minAvailableVideoZoomFactor,
                                             min(zoomFactor, device.activeFormat.videoMaxZoomFactor))
                device.unlockForConfiguration()
            } catch {
                print("❌ Zoom error: \(error.localizedDescription)")
            }
        }
        
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else { return }

        DispatchQueue.main.async {
            self.onPhotoCaptured?(image)
        }
    }
    
    
//    func startSession() {
//        if !session.isRunning {
//            DispatchQueue.global(qos: .userInitiated).async {
//                self.session.startRunning()
//            }
//        }
//    }
    func startSession() {

        guard isConfigured else {
            print("⚠️ Session not configured yet")
            return
        }

        guard !session.isRunning else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
}
#Preview {
    // 1. إنشاء حاوية بيانات وهمية في الذاكرة المؤقتة فقط للـ Preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    
    // 2. تجهيز غرفة تجريبية
    let sampleRoom = Room(
        name: "Mission District Mural Hunt",
        code: "JSR-777",
        category: "Creative",
        location: "Outdoor",
        maxPhotos: 9
    )
    
    // إدخال الغرفة في الـ Context المؤقت
    container.mainContext.insert(sampleRoom)
    
    return RoomCamera(
        room: sampleRoom,
        isShowingFeed: .constant(false),
        onPhotoCaptured: { image in
            print("Photo captured successfully")
        }
    )
    .modelContainer(container)
}
