//
//  Onboarding2.swift
//  Jisr
//
//  Created by Sarah on 03/12/1447 AH.
//


import SwiftUI
import Combine
import AVKit

struct Onboarding2View: View {
    @State private var navigateToName = false
    @Environment(\.dismiss) var dismiss

    var body: some View {

        ZStack {

            Color.backgroundcolor
                .ignoresSafeArea()

            ScrollView {
                
                VStack(spacing: 0) {
                    
                    // 🔹 VIDEO + SKIP OVERLAY
                    ZStack(alignment: .topTrailing) {
                        
                        if let url = Bundle.main.url(forResource: "onboarding2", withExtension: "mp4") {
                            AutoPlayVideoPlayer(url: url)
                                .frame(maxWidth: .infinity)
                                .frame(height: 410)
                                .clipped()
                                .offset(x: -55)
                                .offset(y: -65)

                            //    .ignoresSafeArea()
                        }
                        
                        Image("on2")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 420)
                        
                        Button("Skip") {
                            navigateToName = true
                        }
                        .font(.Ubuntu(size: 16))
                        .foregroundColor(.gray)
                        .padding(.trailing, 24)
                        .padding(.top, 16)
                    }
                    
                    .navigationDestination(isPresented: $navigateToName) {
                        NameView()
                    }
                    
                    
                    Spacer()
                    
                    // 🔹 CARD SECTION
                    ZStack(alignment: .bottom) {
                        
                        Image("onboCard")
                            .resizable()
                            .scaledToFit()
                            .offset(y: 60)
                        
                        VStack(alignment: .leading, spacing: 25) {
                            
                            Text("Every hobby has a home")
                                .font(.UbuntuBold(size: 26))
                                .fontWeight(.bold)
                            
                            Text("Jisr connects you with people who share your hobbies and gives your group a shared prompt. one thing to do, discover, or make together.")
                                .font(.Ubuntu(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                
                                Button(action: {
                                    dismiss()
                                }) {
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Circle().fill(Color.button))
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Circle().fill(Color.gray.opacity(0.3)).frame(width: 8)
                                    Circle().fill(Color.gray.opacity(0.8)).frame(width: 8)
                                    Circle().fill(Color.gray.opacity(0.3)).frame(width: 8)
                                }
                                
                                Spacer()
                                
                                NavigationLink(destination: Onboarding3View()) {
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Circle().fill(Color.button))
                                }
                            }
                            .padding(.top, 35)
                            
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                    
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}


#Preview {
    Onboarding2View()
}
