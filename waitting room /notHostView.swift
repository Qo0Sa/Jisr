//
//  notHostView.swift
//  Jisr
//
//  Created by Wed Ahmed Alasiri on 17/05/2026.
//



import SwiftUI

struct WaitingRoomForNotHostView: View {

    
        var body: some View {
            ZStack(alignment: .bottom) { // جعل العناصر تترتب فوق بعضها
                
                // 1. الخلفية الثابتة
                Image("yellowbg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // 2. المحتوى الأساسي
                VStack {
                    
                    
                    // MARK: Header & Mission & Code (العناصر الثابتة في الأعلى)
                    VStack {
                        
                        // الهيدر
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            Text("Room Name")
                                .font(.system(size: 22, weight: .bold))
                            Spacer()
                            Color.clear.frame(width: 24)
                        }
                        //                    .padding(.top, 10)
                        .offset(y:-30)
                        
                        // بطاقة المهمة
                        VStack(alignment: .leading, spacing: 12) {
                            
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
                                    .padding(.horizontal, -10)
                         //         .padding(.top, 22)
                                    .offset(y: -120)
                        
                        // زر النسخ (نهاية العناصر الثابتة)
                        HStack {
                            Label("5", systemImage: "person.fill")

                        }
                        .offset(y:-100)
                        
                    }
                    .padding(.horizontal, 25)
                    
                    
                    // MARK: ScrollView (تبدأ من هنا وتأخذ باقي الشاشة)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 15) {
                            // قائمة المستخدمين
                            UserCard(name: "ess", image: "person1")
                            UserCard(name: "ayad.200", image: "person1")
                            UserCard(name: "charlie alixander", image: "person1")
                            UserCard(name: "lionnn.15", image: "person1")
                            UserCard(name: "wiliam better.2", image: "person1")
                            UserCard(name: "New Player 1", image: "person1")
                            UserCard(name: "New Player 2", image: "person1")
                            
                            // مساحة إضافية في نهاية السكرول عشان آخر اسم ما يغطي عليه زر الـ Start
                            Color.clear.frame(height: 30)
                        }
    //                    .padding(.top, 20)
                        .padding(.horizontal)
                        .padding(.vertical,40)

                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .offset(y:-90)
                    
                }
                
              
                }
            }
        
        
        // كرت المستخدم (نفسه بدون تغيير)
    struct UserCard: View {
        
        let name: String
        let image: String

        var body: some View {

            HStack(spacing: 15) {

                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())

                Spacer()
                Text(name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.trailing, 60) // ← يعطي مساحة بعد الاسم

            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.6))
            .cornerRadius(45)
            .fixedSize() // ✨ هذا المهم
        }
    }
    }

#Preview {
    WaitingRoomForNotHostView()
}
