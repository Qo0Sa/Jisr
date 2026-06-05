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
    @State private var showError = false
    
    // 💡 تفعيل علامة التسجيل لقطع مسار الأونبوردنق فور الانتقال للمين
    @AppStorage("hasRegistered") private var hasRegistered: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer().frame(height: 60)
                
                PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.08))
                            .frame(width: 188, height: 188)
                        
                        if let image = viewModel.profileImage {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 188, height: 188)
                                .clipShape(Circle())
                        } else {
                            if viewModel.name.isEmpty {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.black.opacity(0.3))
                            } else {
                                Text(String(viewModel.name.prefix(1)).uppercased())
                                    .font(.system(size: 70, weight: .bold))
                                    .foregroundColor(.black.opacity(0.6))
                            }
                        }
                        
                        Circle()
                            .fill(Color.black)
                            .frame(width: 42, height: 42)
                            .overlay { Image(systemName: "plus").foregroundColor(.white) }
                            .offset(x: 60, y: 60)
                    }
                }
                .onChange(of: viewModel.selectedPhoto) {
                    Task { await viewModel.loadImage() }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Write your name")
                        .font(.UbuntuBold(size: 20))
                        .foregroundColor(.button)
                    
                    TextField("Ex.Sarah", text: $viewModel.name)
                        .padding()
                        .background(Color.field)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    if showError && viewModel.name.isEmpty {
                        Text("Please enter your name")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.leading, 4)
                    }
                }
                .padding(.horizontal, 35)
                
                Spacer()
                
                Button {
                    if viewModel.name.isEmpty {
                        showError = true
                    } else {
                        showError = false
                        viewModel.saveUser(context: context)
                        
                        // 💡 تفعيل الدخول الثابت وحفظ البيانات وتأكيده فورياً
                        hasRegistered = true
                        try? context.save()
                        
                        goToMain = true
                    }
                } label: {
                    Text("Next")
                        .font(.UbuntuBold(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 209, height: 64)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 99))
                }
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .background(Color.backgroundcolor)
            .navigationDestination(isPresented: $goToMain) {
                MainView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: User.self, inMemory: true)
}
