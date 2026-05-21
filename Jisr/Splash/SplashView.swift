//
//  SplashView.swift
//  Jisr
//
//  Created by Sarah on 02/12/1447 AH.
//

import SwiftUI
import AVKit

struct SplashView: View {

    @State private var isFinished = false

    var body: some View {

        if isFinished {
            OnboardingView()
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

struct CustomVideoPlayer: UIViewRepresentable {

    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {

        let view = UIView(frame: .zero)

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = UIScreen.main.bounds

        view.layer.addSublayer(playerLayer)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) { }
}

#Preview {
    SplashView()
}
