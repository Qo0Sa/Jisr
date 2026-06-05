//
//  SplashView.swift
//  Jisr
//
//  Created by Sarah on 02/12/1447 AH.
//

import SwiftUI
import AVKit
import SwiftData

struct SplashView: View {
    @State private var isFinished = false
    
    // 💡 فحص حالة التسجيل المسبق لمنع تكرار الأونبوردنق وحفظ حالة الدخول للأبد
    @AppStorage("hasRegistered") private var hasRegistered: Bool = false
    @Query private var users: [User]

    var body: some View {
        if isFinished {
            // 💡 الفحص الذكي: إذا كان مسجل مسبقاً في الـ AppStorage أو قاعدة البيانات تحتوي على يوزر، يفتح الماين فيو فوراً
            if hasRegistered || !users.isEmpty {
                MainView()
            } else {
                OnboardingView()
            }
        } else {
            SplashVideoView(isFinished: $isFinished)
                .ignoresSafeArea()
        }
    }
}

struct SplashVideoView: View {
    @Binding var isFinished: Bool
    private let player: AVPlayer

    init(isFinished: Binding<Bool>) {
        self._isFinished = isFinished
        let url = Bundle.main.url(forResource: "Splash", withExtension: "mp4")!
        self.player = AVPlayer(url: url)
    }

    var body: some View {
        CustomVideoPlayer(player: player)
            .ignoresSafeArea()
            .onAppear {
                player.playImmediately(atRate: 1)
                if let duration = player.currentItem?.asset.duration {
                    let seconds = CMTimeGetSeconds(duration)
                    DispatchQueue.main.asyncAfter(deadline: .now() + (seconds - 0.15)) {
                        isFinished = true
                    }
                }
            }
    }
}

// MARK: - مشغل الفيديو المخصص المصحح هندسياً بدون أخطاء
struct CustomVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false // إخفاء عناصر التحكم لجمالية الـ Splash
        
        // 💡 تم تصحيح السطر هنا لتفادي إيرور الـ Compiler والمحاذاة بشكل كامل وصحيح
        controller.videoGravity = .resizeAspectFill
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

#Preview {
    SplashView()
}
