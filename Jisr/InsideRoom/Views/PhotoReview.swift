//
//  PhotoReview.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//
//  ⚠️ DISABLED — replaced by PhotoPreviewView in InsideRoom/sara/PhotoPreviewView.swift
//

#if false

import SwiftUI

struct PhotoReview: View {
    let capturedImage: UIImage
    let onCancel: () -> Void
    let onSave: (String, String) -> Void

    @State private var thoughtText: String = ""
    @State private var selectedEmoji: String = "😊"

    let emojis = ["😓", "😔", "🤩", "😊", "😆", "😎"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.black.opacity(0.04))
                    .aspectRatio(0.85, contentMode: .fit)
                    .overlay {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Type a thought ...", text: $thoughtText)
                            .font(.Ubuntu(size: 16))
                            .foregroundColor(.black)

                        Divider()

                        HStack {
                            Spacer()
                            Text("\(thoughtText.isEmpty ? 0 : thoughtText.components(separatedBy: .whitespacesAndNewlines).filter({ !$0.isEmpty }).count) words")
                                .font(.system(size: 12))
                                .foregroundColor(.black.opacity(0.4))
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("How does this moment feel?")
                            .font(.UbuntuBold(size: 14))
                            .foregroundColor(.black.opacity(0.6))

                        HStack(spacing: 12) {
                            ForEach(emojis, id: \.self) { emoji in
                                Text(emoji)
                                    .font(.system(size: 26))
                                    .padding(6)
                                    .background(selectedEmoji == emoji ? Color.white : Color.clear)
                                    .clipShape(Circle())
                                    .shadow(color: selectedEmoji == emoji ? .black.opacity(0.1) : Color.clear, radius: 4)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                                            selectedEmoji = emoji
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .padding(12)
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: {
                onSave(thoughtText, selectedEmoji)
            }) {
                Circle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 4)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .fill(Color(red: 0.18, green: 0.18, blue: 0.18))
                            .frame(width: 66, height: 66)
                    )
                    .overlay {
                        Image(systemName: "checkmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
            }
            .padding(.bottom, 24)
        }
        .background(Color("Backgroundcolor").ignoresSafeArea())
    }
}

#endif
