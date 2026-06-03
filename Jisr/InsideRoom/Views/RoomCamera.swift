//
//  RoomCamera.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//

//
//  RoomCamera.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 01/12/1447 AH.
//

import SwiftUI
import SwiftData

struct RoomCamera: View {
    let room: Room
    @Binding var isShowingFeed: Bool
    let onPhotoCaptured: (UIImage) -> Void
    
    @State private var isFlashOn = false
    @State private var zoomScale: String = "1x"
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. الهيدر العلوي المشترك (يمرر العداد ويفعل التبديل للمعرض الحي)
            RoomHeader(
                currentProgress: room.photos?.count ?? 0,
                maxPhotos: room.maxPhotos,
                isShowingFeed: isShowingFeed,
                onGalleryToggle: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isShowingFeed = true // الانتقال لشبكة صور الروم الحية
                    }
                }
            )
            
            // 2. كارد التحدي العائم (PromptCard المتروك للـ CoreML لاحقاً)
            VStack {
                VStack(alignment: .leading, spacing: 8) {
//                    Text(room.name)
//                        .font(.UbuntuBold(size: 18))
//                        .foregroundColor(.black)
//                    
//                    Text("Go together and capture a memorable moment that connects you all!")
//                        .font(.Ubuntu(size: 14))
//                        .foregroundColor(.black.opacity(0.6))
//                        .lineSpacing(3)
                    Text(room.missionTitle)
                        .font(.UbuntuBold(size: 18))
                        .foregroundColor(.black)

                    Text(room.missionDescription)
                        .font(.Ubuntu(size: 14))
                        .foregroundColor(.black.opacity(0.6))
                        .lineSpacing(3)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            
            Spacer()
            
            // 3. منطقة عارضة عدسة الكاميرا (تأثير بولاريد عائم بحواف دائرية ناعمة)
            ZStack {
                RoundedRectangle(cornerRadius: 36)
                    .fill(Color.black.opacity(0.05))
                    .aspectRatio(0.88, contentMode: .fit)
                    .overlay {
                        // هنا يتم ربط الـ AVCaptureSession الفعلي مستقبلاً، حالياً محاكاة أيقونة الكاميرا
                        Image(systemName: "camera.metering.matrix")
                            .font(.system(size: 40))
                            .foregroundColor(.black.opacity(0.1))
                    }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // 4. شريط أدوات التحكم السفلي للكاميرا (فلاش، زوم، زر الالتقاط)
            VStack(spacing: 24) {
                HStack(spacing: 40) {
                    // زر الفلاش
                    Button(action: { isFlashOn.toggle() }) {
                        Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(isFlashOn ? .yellow : .black.opacity(0.6))
                            .frame(width: 44, height: 44)
                            .background(Color("fieldColor"))
                            .clipShape(Circle())
                    }
                    
                    // كبسولة تقريب الزوم (.5x, 1x, 2x)
                    HStack(spacing: 12) {
                        ForEach([".5x", "1x", "2x"], id: \.self) { scale in
                            Text(scale)
                                .font(.UbuntuBold(size: 13))
                                .foregroundColor(zoomScale == scale ? .white : .black.opacity(0.5))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(zoomScale == scale ? Color.black.opacity(0.7) : Color.clear)
                                .clipShape(Capsule())
                                .onTapGesture { zoomScale = scale }
                        }
                    }
                    .padding(4)
                    .background(Color("fieldColor"))
                    .clipShape(Capsule())
                    
                    // زر تبديل الكاميرا (أمامية/خلفية)
                    Button(action: {}) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                            .frame(width: 44, height: 44)
                            .background(Color("fieldColor"))
                            .clipShape(Circle())
                    }
                }
                
                // زر الالتقاط الدائري المعتمد في هوية التطبيق البصرية
                Button(action: {
                    // محاكاة التقاط لقطة وهمية وتمريرها للشاشة التالية فوراً للتوثيق
                    if let mockImage = UIImage(systemName: "photo.fill") {
                        onPhotoCaptured(mockImage)
                    }
                }) {
                    Circle()
                        .stroke(Color.black.opacity(0.15), lineWidth: 5)
                        .frame(width: 84, height: 84)
                        .overlay(
                            Circle()
                                .fill(Color(red: 0.18, green: 0.18, blue: 0.18))
                                .frame(width: 68, height: 68)
                        )
                }
                .padding(.bottom, 24)
            }
        }
        .background(Color("Backgroundcolor").ignoresSafeArea())
    }
}
#Preview {
    // 1. إنشاء حاوية بيانات وهمية في الذاكرة المؤقتة فقط للـ Preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    
    // 2. تجهيز غرفة تجريبية
    let sampleRoom = Room(
        name: "Mission District Mural Hunt",
        code: "JSR-777",
        category: "Creative",
        location: "Outdoor",
        maxPhotos: 9
    )
    
    // إدخال الغرفة في الـ Context المؤقت
    container.mainContext.insert(sampleRoom)
    
    return RoomCamera(
        room: sampleRoom,
        isShowingFeed: .constant(false),
        onPhotoCaptured: { image in
            print("Photo captured successfully")
        }
    )
    .modelContainer(container)
}
