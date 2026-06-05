



//
//  ProfileView.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 01/12/1447 AH.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    // 💡 تفعيل الاستقبال: استقبال الـ Binding من الماين فيو لتصفير المسار فوراً والرجوع للجذر بسلامة
    @Binding var waitingDestination: WaitingDestination?
    
    @Query private var users: [User]
    
    @State private var selectedTab: String = "Photos"
    @State private var selectedCategory: String = "All"
    
    @State private var isEditingName = false
    @State private var newName: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    var currentUser: User? { users.first }
    
    let categoryFilters = [
        (name: "All", icon: "square.grid.2x2.fill", color: "buttonColor"),
        (name: "Physical", icon: "figure.run", color: "physicalColor"),
        (name: "Cognitive", icon: "book.closed.fill", color: "cognitiveColor"),
        (name: "Creative", icon: "paintpalette.fill", color: "creativeColor")
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        try? context.save()
                        if waitingDestination != nil {
                            waitingDestination = nil // تصفير المسار للعودة المباشرة للمين فيو وتجنب الأونبوردنق
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.06))
                            .frame(width: 110, height: 110)
                        
                        if let data = currentUser?.profileImage, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.black.opacity(0.3))
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                            ZStack {
                                Circle()
                                    .fill(Color("buttonColor"))
                                    .frame(width: 23, height: 23)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                Image(systemName: "plus").font(.system(size: 12, weight: .medium)).foregroundColor(.white)
                            }
                        }
                    }
                    .onChange(of: selectedPhotoItem) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                if let user = currentUser {
                                    user.profileImage = data
                                    try? context.save()
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        newName = currentUser?.name ?? "myname"
                        withAnimation(.easeInOut(duration: 0.2)) { isEditingName = true }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentUser?.name ?? "myname").font(.UbuntuBold(size: 24)).foregroundColor(.black)
                            Image(systemName: "pencil").font(.system(size: 18)).foregroundColor(.black.opacity(0.6))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 10)
                
                HStack {
                    Text("History").font(.UbuntuBold(size: 20)).foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                HStack(spacing: 0) {
                    Button(action: { selectedTab = "Photos" }) {
                        Text("Photos")
                            .font(.UbuntuBold(size: 16))
                            .foregroundColor(selectedTab == "Photos" ? .white : .black.opacity(0.5))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(selectedTab == "Photos" ? Color.black.opacity(0.8) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                    }
                    Button(action: { selectedTab = "Rooms" }) {
                        HStack(spacing: 6) {
                            Image(systemName: "archivebox.fill").font(.system(size: 14))
                            Text("Rooms")
                        }
                        .font(.UbuntuBold(size: 16))
                        .foregroundColor(selectedTab == "Rooms" ? .white : .black.opacity(0.5))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(selectedTab == "Rooms" ? Color.black.opacity(0.8) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 99))
                    }
                }
                .padding(4)
                .frame(height: 50)
                .background(Color("fieldColor"))
                .clipShape(RoundedRectangle(cornerRadius: 99))
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categoryFilters, id: \.name) { filter in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedCategory = filter.name }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: filter.icon).font(.system(size: 18, weight: .medium))
                                    if selectedCategory == filter.name {
                                        Text(filter.name).font(.UbuntuBold(size: 14)).transition(.opacity.combined(with: .move(edge: .leading)))
                                    }
                                }
                                .padding(.horizontal, selectedCategory == filter.name ? 16 : 12)
                                .frame(height: 44)
                                .background(Color(filter.color))                                .foregroundColor(selectedCategory == filter.name ? .white : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 99))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 20)
                
                Divider().padding(.horizontal, 24).padding(.top, 16)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        if selectedTab == "Photos" {
                            ProfilePhotosTabView(selectedCategory: selectedCategory)
                        } else {
                            ProfileRoomsTabView(selectedCategory: selectedCategory)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .background(Color("Backgroundcolor").ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            
            if isEditingName {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea().onTapGesture { isEditingName = false }
                    VStack(spacing: 20) {
                        Text("Edit Name").font(.UbuntuBold(size: 20)).foregroundColor(.black)
                        TextField("Enter your name", text: $newName)
                            .font(.Ubuntu(size: 16)).padding().frame(height: 50)
                            .background(Color("fieldColor")).clipShape(RoundedRectangle(cornerRadius: 14)).autocorrectionDisabled()
                        HStack(spacing: 12) {
                            Button(action: { isEditingName = false }) {
                                Text("Cancel").font(.UbuntuBold(size: 16)).foregroundColor(.gray)
                                    .frame(maxWidth: .infinity).frame(height: 46).background(Color.black.opacity(0.05)).clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            Button(action: saveNameAction) {
                                Text("Save").font(.UbuntuBold(size: 16)).foregroundColor(.white)
                                    .frame(maxWidth: .infinity).frame(height: 46).background(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color("buttonColor").opacity(0.5) : Color("buttonColor")).clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding(24).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 24)).padding(.horizontal, 36).shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                }
                .transition(.opacity)
            }
        }
    }
    
    private func saveNameAction() {
        if let user = currentUser { user.name = newName; try? context.save() }
        withAnimation(.easeInOut(duration: 0.2)) { isEditingName = false }
    }
}

// 💡 تمرير الـ Binding التجريبي الثابت للحفاظ على استقرار الـ Canvas وتأمين الـ Build
#Preview {
    ProfileView(waitingDestination: .constant(.profile))
        .modelContainer(for: [User.self, Room.self, Photo.self], inMemory: true)
}
