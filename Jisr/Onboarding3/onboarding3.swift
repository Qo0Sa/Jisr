//
//  onboarding3.swift
//  Jisr
//
//  Created by Sarah on 04/12/1447 AH.
//



import SwiftUI
import Combine
import AVKit

struct Onboarding3View: View {
    @State private var navigateToName = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
      //  NavigationStack {
            ZStack {
                
                Color.backgroundcolor
                    .ignoresSafeArea()
                
            
                
                VStack {

                    ZStack(alignment: .topTrailing) {

                        if let url = Bundle.main.url(forResource: "onboarding3", withExtension: "mp4") {
                            AutoPlayVideoPlayer(url: url)
                                .frame(maxWidth: .infinity)
                                .frame(height: 410)
                                .clipped()
                                .offset(x: -55)
                                .ignoresSafeArea()
                        }

                        Image("on3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 400)
                            .scaleEffect(1.26)
                            .offset(y: 55)

                    }

                    Spacer()

                    
                    ZStack(alignment: .bottom) {
                        
                        Image("onboCard")
                            .resizable()
                            .scaledToFit()
                            .padding(.bottom, -30)
                        
                        
                        VStack(alignment: .leading, spacing: 25) {
                            
                            Text("Your experiences, built into something real")
                                .font(.UbuntuBold(size: 26))
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)

                            Text("Every room you complete adds a layer to your city. The more you explore, the more it grows.")
                                .font(.Ubuntu(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                
                                Button(action: {
                                    dismiss()
                                }) {
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(Color.button))
                                }
                                .frame(width: 90)
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
                                    Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
                                    Circle().fill(Color.gray.opacity(0.8)).frame(width: 8, height: 8)
                                }
                                
                                Spacer()
                                
                                
                                Button(action: {
                                    navigateToName = true
                                }) {
                                    Text("Start")
                                        .font(.UbuntuBold(size: 16))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(
                                            Capsule().fill(Color.button)
                                        )
                                }
                                .navigationDestination(isPresented: $navigateToName) {
                                                    NameView()
                                                }
                                
                                .frame(width: 90)
                            }
                            .padding(.top, 35)

                        }
                        
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    
                }
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    
    
}

  
    




#Preview {
    Onboarding3View()
}
    
    

