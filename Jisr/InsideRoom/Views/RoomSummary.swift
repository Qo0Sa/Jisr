//
//  RoomSummary.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//

//
//  RoomSummary.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 01/12/1447 AH.
//

import SwiftUI
import SwiftData

struct RoomSummary: View {
    let room: Room
    @Environment(\.dismiss) private var dismiss
    
    // جلب صور الروم لغرض عرضها مكدسة وحفظها
    var roomPhotos: [Photo] {
        room.photos ?? []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - الهيدر العلوي لصفحة الملخص
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            Spacer()
            
            // MARK: - العنوان الرئيسي النصي
            Text("Do You Want To Save These Photos?")
                .font(.UbuntuBold(size: 22))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer().frame(height: 40)
            
            // MARK: - مكدس الكروت المتراكمة ثلاثية الأبعاد (Stacked Cards Geometry)
            ZStack {
                if roomPhotos.isEmpty {
                    // كارد افتراضي في حال لم يتم التقاط صور (لغرض العرض التجريبي والـ Preview)
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.black.opacity(0.04))
                        .frame(width: 280, height: 340)
                        .overlay {
                            Image(systemName: "photo.on.rectangle.angled").foregroundColor(.black.opacity(0.15))
                        }
                } else {
                    // عرض آخر 3 صور مرفوعة على شكل طبقات متراكمة مائلة
                    ForEach(0..<min(roomPhotos.count, 3), id: \.self) { index in
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white)
                            .frame(width: 280 - CGFloat(index * 15), height: 340) // تصغير الأبعاد تدريجياً للطبقات الخلفية
                            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                            .overlay {
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
                            }
                            .offset(y: CGFloat(index * -16)) // دفع الكروت الخلفية لأعلى قليلاً لصناعة العمق
                            .rotationEffect(.degrees(index == 0 ? 0 : (index == 1 ? -4 : 4))) // تمييل الكروت الخلفية عشوائياً
                            .zIndex(Double(4 - index)) // الحفاظ على الصورة الأحدث في المقدمة دائماً
                    }
                    
                    // الكرت الأمامي الرئيسي يعرض تفاصيل الصورة الأحدث مع الاسم والريأكشن
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.03))
                            .aspectRatio(0.9, contentMode: .fit)
                            .overlay {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.black.opacity(0.1))
                            }
                            .padding(12)
                        
                        // شريط اسم المستخدم والريأكشن العائم في أسفل البولاريد
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(roomPhotos.first?.user?.name ?? "myname")
                                    .font(.UbuntuBold(size: 14))
                                    .foregroundColor(.black.opacity(0.8))
                                Text("text text text text texttext text text text texttext")
                                    .font(.Ubuntu(size: 11))
                                    .foregroundColor(.black.opacity(0.4))
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text("😆")
                                .font(.system(size: 22))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .frame(width: 280, height: 340)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .black.opacity(0.08), radius: 15, y: 10)
                    .zIndex(5)
                }
            }
            .frame(height: 380)
            
            Spacer()
            
            // MARK: - زر حفظ وتنزيل الصور النهائي لألبوم الجهاز
            Button(action: {
                // أكشن الحفظ الفعلي في الـ Photos Library المشتركة
                dismiss() // العودة للشاشة الرئيسية بعد الحفظ بنجاح
            }) {
                HStack(spacing: 8) {
                    Text("Save Photos")
                        .font(.UbuntuBold(size: 20))
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(Color(red: 0.18, green: 0.18, blue: 0.18))
                .clipShape(RoundedRectangle(cornerRadius: 99))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color("Backgroundcolor").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    // 1. تعريف جميع الكلاسات المترابطة داخل الحاوية المؤقتة لضمان عدم حدوث كراش
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    
    // 2. تجهيز بيانات الغرفة والمستخدم التجريبي
    let sampleRoom = Room(
        name: "Mission District Mural Hunt",
        code: "JSR-99X",
        category: "Creative",
        location: "Outdoor",
        maxPhotos: 9
    )
    let sampleUser = User(name: "Wteen")
    
    // 3. حقن صور تجريبية داخل الغرفة لنرى تأثير المكدس المائل ثلاثي الأبعاد (Stacked Cards) بالـ Canvas
    let photo1 = Photo(url: "photo_1", room: sampleRoom, user: sampleUser)
    let photo2 = Photo(url: "photo_2", room: sampleRoom, user: sampleUser)
    let photo3 = Photo(url: "photo_3", room: sampleRoom, user: sampleUser)
    
    // إدخال كافة العناصر في سياق قاعدة البيانات المؤقتة
    container.mainContext.insert(sampleRoom)
    container.mainContext.insert(sampleUser)
    container.mainContext.insert(photo1)
    container.mainContext.insert(photo2)
    container.mainContext.insert(photo3)
    
    return RoomSummary(room: sampleRoom)
        .modelContainer(container)
}
