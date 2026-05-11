//
//  NameView.swift
//  Jisr
//
//  Created by Sarah on 24/11/1447 AH.
//

import SwiftUI
import SwiftData
import PhotosUI

struct NameView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = UserViewModel()
    @State private var goToMain = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 60) // ← غير الرقم حسب ما تبين
                
                // صورة البروفايل
                PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                    if let image = viewModel.profileImage {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 90, height: 90)
                            .overlay {
                                Image(systemName: "plus")
                                    .foregroundStyle(.gray)
                            }
                    }
                }
                .onChange(of: viewModel.selectedPhoto) {
                    Task { await viewModel.loadImage() }
                }
                
                // حقل الاسم
                TextField("write your name", text: $viewModel.name)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.field)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 40)
                
                // زر Next
                Button("next") {
                    viewModel.saveUser(context: context)
                    goToMain = true
                }
                .disabled(!viewModel.isValid)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(viewModel.isValid ? Color.button : Color.gray)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .background(Color.backgroundcolor) 
            .navigationDestination(isPresented: $goToMain) {
                MainView()
            }
        }
    }
}
