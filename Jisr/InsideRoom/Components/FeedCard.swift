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
    let userImageData: Data?
    let thoughtText: String
    let emojiReaction: String
    let imageData: Data?

    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // منطقة عرض الصورة الأساسية داخل البولاريد
            ZStack(alignment: .bottomLeading) {
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color.black.opacity(0.04))
//                    .aspectRatio(0.85, contentMode: .fit) // أبعاد متناسقة للصور المستطيلة بالمعرض
//                    .overlay {
//                        Image(systemName: "photo.fill")
//                            .font(.system(size: 30))
//                            .foregroundColor(.black.opacity(0.1))
//                    }
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.04))
                    .aspectRatio(0.85, contentMode: .fit)
                    .overlay {

                        if let imageData,
                           let uiImage = UIImage(data: imageData) {

                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()

                        } else {

                            Image(systemName: "photo.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.black.opacity(0.1))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // الطبقة الشفافة السفلية العائمة (اسم المستخدم والريأكشن)
              
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.black.opacity(0.15))
                            .frame(width: 24, height: 24)
                            .overlay {
                                if let data = userImageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                } else {
                                    Text(String(userName.prefix(1)).uppercased())
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }

                        Text(userName)
                            .font(.UbuntuBold(size: 12))
                            .foregroundColor(.black.opacity(0.8))
                    }
                    
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial) // تأثير Glassmorphic ناعم جداً
                .clipShape(RoundedRectangle(cornerRadius: 99))
                .padding(8)
            }
            
            // التفكير اللحظي المكتوب أسفل كارد البولاريد
            if !thoughtText.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Text(thoughtText)
                            .font(.Ubuntu(size: 12))
                            .foregroundColor(.black.opacity(0.6))
                            .lineLimit(isExpanded ? nil : 2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(emojiReaction)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 10)
                    .padding(.bottom, isExpanded ? 2 : 6)

                    if isExpanded {
                        Text("Show less")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.black.opacity(0.35))
                            .padding(.horizontal, 8)
                            .padding(.bottom, 6)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }
            } else {
                HStack {
                    Spacer()
                    Text(emojiReaction)
                        .font(.system(size: 16))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                }
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
        FeedCard(
            userName: "Sara",
            userImageData: nil,
            thoughtText: "text",
            emojiReaction: "😆",
            imageData: nil
        )
    }
}
