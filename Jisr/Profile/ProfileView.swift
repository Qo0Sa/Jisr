



//
//  ProfileView.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 01/12/1447 AH.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query private var users: [User]
    
    @State private var selectedTab: String = "Photos"
    @State private var selectedCategory: String = "Creative"
    
    // 💡 متغيرات جديدة للتحكم في بوب أب تعديل الاسم
    @State private var isEditingName = false
    @State private var newName: String = ""
    
    var currentUser: User? {
        users.first
    }
    
    let categoryFilters = [
        (name: "Physical", icon: "figure.run", color: "physicalColor"),
        (name: "Mental", icon: "book.closed.fill", color: "cognitiveColor"),
        (name: "Creative", icon: "paintpalette.fill", color: "creativeColor")
    ]
    
    var body: some View {
        ZStack {
            // واجهة البروفايل الأساسية
            VStack(spacing: 0) {
                
                // MARK: - الهيدر العلوي لصفحة البروفايل
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // MARK: - معلومات المستخدم (الأفاتار والاسم مع زر التعديل)
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
                    
                    // 💡 زر الاسم والقلم لتفعيل التعديل عند الضغط
                    Button(action: {
                        newName = currentUser?.name ?? "myname"
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditingName = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentUser?.name ?? "myname")
                                .font(.UbuntuBold(size: 24))
                                .foregroundColor(.black)
                            
                            Image(systemName: "pencil")
                                .font(.system(size: 18))
                                .foregroundColor(.black.opacity(0.6))
                        }
                    }
                    .buttonStyle(PlainButtonStyle()) // للحفاظ على التصميم بدون تلوين الزر بالأزرق
                }
                .padding(.top, 10)
                
                HStack {
                    Text("History")
                        .font(.UbuntuBold(size: 20))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // MARK: - كبسولة التحكم بالتبويبات المخصصة (Photos / Rooms)
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
                            Image(systemName: "archivebox.fill")
                                .font(.system(size: 14))
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
                
                // MARK: - شريط الأيقونات المخصص (الكبسولات الذكية الممتدة بالتفاعل)
                HStack(spacing: 12) {
                    ForEach(categoryFilters, id: \.name) { filter in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedCategory = filter.name
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: filter.icon)
                                    .font(.system(size: 18, weight: .medium))
                                
                                if selectedCategory == filter.name {
                                    Text(filter.name)
                                        .font(.UbuntuBold(size: 14))
                                        .transition(.opacity.combined(with: .move(edge: .leading)))
                                }
                            }
                            .padding(.horizontal, selectedCategory == filter.name ? 16 : 12)
                            .frame(height: 44)
                            .background(Color(filter.color))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Divider()
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                // MARK: - استدعاء الـ Subviews المنفصلة بشكل نظيف وديناميكي
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        if selectedTab == "Photos" {
                            ProfilePhotosTabView(selectedCategory: selectedCategory)
                        } else {
                            ProfileRoomsTabView(selectedCategory: selectedCategory)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .background(Color("Backgroundcolor").ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            
            // MARK: - 💡 نافذة منبثقة مخصصة لتعديل الاسم (Custom Edit Popup)
            if isEditingName {
                ZStack {
                    // خلفية ضبابية داكنة مع إمكانية الإغلاق عند النقر بالخارج
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { isEditingName = false }
                    
                    // كارد التعديل الأبيض المصمم بلغة هوية التطبيق
                    VStack(spacing: 20) {
                        Text("Edit Name")
                            .font(.UbuntuBold(size: 20))
                            .foregroundColor(.black)
                        
                        TextField("Enter your name", text: $newName)
                            .font(.Ubuntu(size: 16))
                            .padding()
                            .frame(height: 50)
                            .background(Color("fieldColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .autocorrectionDisabled()
                        
                        HStack(spacing: 12) {
                            // زر إلغاء الأمر
                            Button(action: { isEditingName = false }) {
                                Text("Cancel")
                                    .font(.UbuntuBold(size: 16))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 46)
                                    .background(Color.black.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // زر حفظ الاسم في SwiftData
                            Button(action: saveNameAction) {
                                Text("Save")
                                    .font(.UbuntuBold(size: 16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 46)
                                    .background(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color("buttonColor").opacity(0.5) : Color("buttonColor"))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 36)
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                }
                .transition(.opacity)
            }
        }
    }
    
    // 💡 دالة الحفظ والتعديل الفعلي داخل السويفت داتا
    private func saveNameAction() {
        if let user = currentUser {
            user.name = newName
            try? context.save() // حفظ التعديل في قاعدة البيانات
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            isEditingName = false
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [User.self, Room.self, Photo.self], inMemory: true)
}
