//
//  MaxPhotosPopup.swift
//  Jisr
//
//  Created by Sarah Alnasser on 09/06/2026.
//

import SwiftUI

struct MaxPhotosPopup: View {
    @Binding var isPresented: Bool
    let maxPhotos: Int

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("📸")
                        .font(.system(size: 40))

                    Text("Photo limit reached")
                        .font(.UbuntuBold(size: 22))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    Text("This room only allows \(maxPhotos) photo\(maxPhotos == 1 ? "" : "s").\nView the gallery to see what's been captured.")
                        .font(.Ubuntu(size: 15))
                        .foregroundColor(.black.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.top, 10)

                Button(action: { isPresented = false }) {
                    Text("Got it")
                        .font(.UbuntuBold(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(red: 0.18, green: 0.18, blue: 0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 99))
                }
            }
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .padding(.horizontal, 36)
            .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 12)
        }
    }
}

#Preview {
    MaxPhotosPopup(isPresented: .constant(true), maxPhotos: 9)
}
