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
        
        VideoPlayer(player: player)
            .onAppear {
                player.play()
                
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: player.currentItem,
                    queue: .main
                ) { _ in
                    isFinished = true
                }
            }
    }
}
