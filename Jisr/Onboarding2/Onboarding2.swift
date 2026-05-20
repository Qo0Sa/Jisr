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

    var body: some View {
        
        NavigationStack {
            ZStack {
                
                Color.backgroundcolor
                    .ignoresSafeArea()
                
            
                
                VStack {
                    
                    HStack {
                                           Spacer()
                                           Button("Skip") {
                                               navigateToName = true                                           }
                                           .font(.Ubuntu(size: 16))
                                           .foregroundColor(.gray)
                                           .padding(.horizontal, 24)
                                           .padding(.top, 16)
                                       }
                    
                    .navigationDestination(isPresented: $navigateToName) {
                        NameView()
                    }
                                       
                            
                    Spacer()
                    ZStack {
                           
                           if let url = Bundle.main.url(forResource: "onboarding1", withExtension: "mp4") {
                               AutoPlayVideoPlayer(url: url)
                                   .frame(width: 400, height: 400)
                                   .clipped()
                           }
                           
                           
                        Image("on1")
                               .resizable()
                               .scaledToFit()
                               .frame(width: 350, height: 350)
                             //  .opacity(0.9)
                            
                               
                        
                        
                        
                       }
                       
                    
                       Spacer()
                       
                    
                    ZStack(alignment: .bottom) {
                        
                        Image("onboCard")
                            .resizable()
                            .scaledToFit()
                            .padding(.bottom, -30)
                        
                        
                        VStack(alignment: .leading, spacing: 25) {
                            
                            Text("Every hobby has a home")
                                .font(.UbuntuBold(size: 26))
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)

                            Text("Jisr connects you with people who share your hobbies and gives your group a shared prompt. one thing to do, discover, or make together.")
                                .font(.Ubuntu(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                // ✅ نفس حجم الزر بس invisible للتوازن
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 44, height: 44)
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
                                    Circle().fill(Color.gray.opacity(0.8)).frame(width: 8, height: 8)
                                    Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // action
                                }) {
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
        }
    }
    
}

  
    




#Preview {
    Onboarding2View()
}
    
    

