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
    
    @State private var isFlashOn = false
    @State private var zoomScale: String = "1x"
    @StateObject private var camera = CameraManager()

    var body: some View {
        VStack(spacing: 0) {
            // 1. الهيدر العلوي المشترك (يمرر العداد ويفعل التبديل للمعرض الحي)
            RoomHeader(
                currentProgress: room.photos?.count ?? 0,
                maxPhotos: room.maxPhotos,
                isShowingFeed: isShowingFeed,
                onGalleryToggle: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isShowingFeed = true // الانتقال لشبكة صور الروم الحية
                    }
                }
            )
            
            // 2. كارد التحدي العائم (PromptCard المتروك للـ CoreML لاحقاً)
            VStack {
                VStack(alignment: .leading, spacing: 8) {
//                    Text(room.name)
//                        .font(.UbuntuBold(size: 18))
//                        .foregroundColor(.black)
//                    
//                    Text("Go together and capture a memorable moment that connects you all!")
//                        .font(.Ubuntu(size: 14))
//                        .foregroundColor(.black.opacity(0.6))
//                        .lineSpacing(3)
                    Text(room.missionTitle)
                        .font(.UbuntuBold(size: 18))
                        .foregroundColor(.black)

                    Text(room.missionDescription)
                        .font(.Ubuntu(size: 14))
                        .foregroundColor(.black.opacity(0.6))
                        .lineSpacing(3)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            
            Spacer()
            
            // 3. منطقة عارضة عدسة الكاميرا (تأثير بولاريد عائم بحواف دائرية ناعمة)
//            ZStack {
//                RoundedRectangle(cornerRadius: 36)
//                    .fill(Color.black.opacity(0.05))
//                    .aspectRatio(0.88, contentMode: .fit)
//                    .overlay {
//                        // هنا يتم ربط الـ AVCaptureSession الفعلي مستقبلاً، حالياً محاكاة أيقونة الكاميرا
//                        Image(systemName: "camera.metering.matrix")
//                            .font(.system(size: 40))
//                            .foregroundColor(.black.opacity(0.1))
//                    }
//            }
            CameraPreview(session: camera.session)
                .aspectRatio(0.88, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 36))
                .padding(.horizontal, 24)
            
//            .padding(.horizontal, 24)
            
            Spacer()
            
            // 4. شريط أدوات التحكم السفلي للكاميرا (فلاش، زوم، زر الالتقاط)
            VStack(spacing: 24) {
                HStack(spacing: 40) {
                    // زر الفلاش
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
                    
                    // كبسولة تقريب الزوم (.5x, 1x, 2x)
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
                                }                        }
                    }
                    .padding(4)
                    .background(Color("fieldColor"))
                    .clipShape(Capsule())
                    
                    // زر تبديل الكاميرا (أمامية/خلفية)
                    Button(action: {camera.switchCamera()}) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                            .frame(width: 44, height: 44)
                            .background(Color("fieldColor"))
                            .clipShape(Circle())
                    }
                }
                
                // زر الالتقاط الدائري المعتمد في هوية التطبيق البصرية
//                Button(action: {
//                    // محاكاة التقاط لقطة وهمية وتمريرها للشاشة التالية فوراً للتوثيق
//                    if let mockImage = UIImage(systemName: "photo.fill") {
//                        onPhotoCaptured(mockImage)
//                    }
//                })
                Button(action: {
                    camera.capturePhoto()
                })
                {
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
        .background(Color("Backgroundcolor").ignoresSafeArea() )
//        .onAppear {
//            camera.onPhotoCaptured = { image in
//                onPhotoCaptured(image)
//            }
//        }
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

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()

            DispatchQueue.main.async {
                self.objectWillChange.send()
            }

            print("✅ SESSION RUNNING = \(self.session.isRunning)")
        }
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
        
        // 💡 وظيفة التحكم بالزوم الرقمي لعدسة الكاميرا حياً (.5x, 1x, 2x)
        func setZoom(scale: String) {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            let factor: CGFloat
            switch scale {
            case ".5x": factor = 1.0 // العدسات العادية تبدأ من 1.0 كأقل تقريب رقمي متاح نظامياً
            case "2x":  factor = 2.0
            default:    factor = 1.0
            }
            
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
                device.unlockForConfiguration()
            } catch {
                print("❌ Zoom adjustment error: \(error.localizedDescription)")
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
    
    
    func startSession() {
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
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
