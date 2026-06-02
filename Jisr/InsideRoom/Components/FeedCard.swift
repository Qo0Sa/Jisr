//
//  FeedCard.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//

//
//  FeedCard.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 01/12/1447 AH.
//

import SwiftUI

struct FeedCard: View {
    let userName: String
    let thoughtText: String
    let emojiReaction: String
    
    var body: some View {
        VStack(spacing: 0) {
            // منطقة عرض الصورة الأساسية داخل البولاريد
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.04))
                    .aspectRatio(0.85, contentMode: .fit) // أبعاد متناسقة للصور المستطيلة بالمعرض
                    .overlay {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.black.opacity(0.1))
                    }
                
                // الطبقة الشفافة السفلية العائمة (اسم المستخدم والريأكشن)
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.black.opacity(0.1))
                            .frame(width: 24, height: 24)
                            .overlay(Image(systemName: "person.fill").font(.system(size: 10)).foregroundColor(.white))
                        
                        Text(userName)
                            .font(.UbuntuBold(size: 12))
                            .foregroundColor(.black.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Text(emojiReaction)
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial) // تأثير Glassmorphic ناعم جداً
                .clipShape(RoundedRectangle(cornerRadius: 99))
                .padding(8)
            }
            
            // التفكير اللحظي المكتوب أسفل كارد البولاريد
            if !thoughtText.isEmpty {
                Text(thoughtText)
                    .font(.Ubuntu(size: 12))
                    .foregroundColor(.black.opacity(0.6))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
            }
        }
        .padding(8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ZStack {
        Color("Backgroundcolor").ignoresSafeArea()
        FeedCard(userName: "myname", thoughtText: "text text text text text text text text text text", emojiReaction: "😆")
            .frame(width: 180)
    }
}
