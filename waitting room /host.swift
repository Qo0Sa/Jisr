//
//  host.swift
//  Jisr
//
//  Created by Wed Ahmed Alasiri on 12/05/2026.
//

import SwiftUI

struct WaitingRoomView: View {

    var body: some View {

        ZStack {

            Image("yellowbg") // اسم الصورة في Assets
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                
                    HStack {
                        Button(action: {

                        }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.black.opacity(0.85))
                    }
                    
                    
                    Spacer()

                    Text("Room Name")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black.opacity(0.85))

                    Spacer()

                    Color.clear
                        .frame(width: 28)
                }
                .padding(.horizontal, 28)
                .padding(.top, 65)

                // MARK: Mission Card

                VStack(alignment: .leading, spacing: 14) {

                    HStack(alignment: .top) {

                        Text("Mission District Mural Hunt")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black.opacity(0.75))

                        Spacer()
                        Button(action: {

                        }) {
                            Image(systemName: "arrow.trianglehead.2.clockwise")
                                .font(.system(size: 20))
                                .foregroundColor(.black.opacity(0.75))
                        }
                    }

                    Text("Go to Mission District and each photograph the mural that moved you the most")
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 233/255, green: 227/255, blue: 214/255))
                        .cornerRadius(18)

                }
                .padding(16)
                .background(Color(red: 244/255, green: 242/255, blue: 237/255))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black.opacity(0.7), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 0, x: 0, y: 3)
                .padding(.horizontal, 20)
//                .padding(.top, 22)
                .offset(y: -95)

                // MARK: Room Code

                HStack {

                    HStack(spacing: 6) {

                        Image(systemName: "person.fill")

                        Text("5")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .offset(y: -100)

                    Spacer()

                    HStack(spacing: 14) {
                        
                        HStack{
                            Text("ABC123")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.gray.opacity(0.8))
                                .frame(width: 130, height: 38)
                                .cornerRadius(28)
                            
                            Button(action: {
                                
                            }) {
                                Image(systemName: "document.on.document.fill")
                                    .font(.system(size: 22))
                                    .offset(x:-49)
                                    .foregroundColor(.gray.opacity(0.8))
                                    .offset(x : 35)
                            }
                        }
                        .background(Color.white.opacity(0.75))
                        .cornerRadius(28)
                        .frame(width: 150, height: 28)
                        .offset(x : -50)
                        
                        
                        
                        
               
                        
                        
                        Button(action: {
                            
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24))
                                .foregroundColor(.black)

                        }
                    }
                    .offset(y: -100)
                }
                .padding(.horizontal, 42)
                .padding(.top, 26)

                // MARK: Users

                ScrollView(showsIndicators: false) {
//here will be the foreach loop later
                    VStack(spacing: 28) {

                        UserCard(name: "ahmed", image: "person1")

                        UserCard(name: "ayad.200", image: "person1")

                        UserCard(name: "charlie alixander", image: "person1")

                        UserCard(name: "lionnn.15", image: "person1")

                        UserCard(name: "wiliam better.2", image: "person1")
                    }
                    .padding(.top, 30)
                    .padding(.horizontal, 34)
                    .padding(.bottom, 10)
                }
//                .frame(maxWidth: 400)
                .frame(maxHeight: 920) // هنا تتحكمين لنهاية السكروول
                .offset(y: -100)
                .padding(.top, 26)



//                Spacer()

                
            }
            .offset(y:-130)
            
            
            VStack{
                ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.yellow.opacity(0.95),
                                Color.yellow.opacity(0.45),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 10,
                            endRadius: 180
                        )
                    )
                    .frame(width: 340, height: 340)
                    .blur(radius: 35)
                    .offset(y: -10)
                
                
                Button(action: {
                    
                }) {
                    
                    Text("Start")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 210, height: 70)
                        .background(Color(red: 43/255, green: 39/255, blue: 41/255))
                        .cornerRadius(50)
                }
                .padding(.bottom, 40)
            }
            }
            .offset(y: 370)
        }
        
    }
}

// MARK: - User Card

struct UserCard: View {

    let name: String
    let image: String

    var body: some View {

        HStack(spacing: 20) {

            

            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                .offset(x: -7)
            
            
            Text(name)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.black.opacity(0.78))
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 18)
        .frame(height: 90)
        .background(Color.white.opacity(0.45))
        .cornerRadius(65)
    }
}

// MARK: - Preview

#Preview {
    WaitingRoomView()
}
