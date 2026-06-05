//
//  RoomSummary.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//

import SwiftUI
import SwiftData

struct RoomSummary: View {
    let room: Room
    @Environment(\.dismiss) private var dismiss
    
    var roomPhotos: [Photo] { room.photos ?? [] }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - الهيدر العلوي لصفحة الملخص
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left").font(.system(size: 22, weight: .bold)).foregroundColor(.black)
                }
                Spacer()
                
                // 💡 تفعيل زر الإغلاق (X) لبث إشارة مشفرة للـ MainView لتصفير التنقل والرجوع الفوري للجذر
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        NotificationCenter.default.post(name: NSNotification.Name("DismissRoomFlow"), object: nil)
                        dismiss()
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            Spacer()
            Text("Do You Want To Save These Photos?").font(.UbuntuBold(size: 22)).foregroundColor(.black).multilineTextAlignment(.center).padding(.horizontal, 32)
            Spacer().frame(height: 40)
            
            ZStack {
                if roomPhotos.isEmpty {
                    RoundedRectangle(cornerRadius: 28).fill(Color.black.opacity(0.04)).frame(width: 280, height: 340)
                        .overlay { Image(systemName: "photo.on.rectangle.angled").foregroundColor(.black.opacity(0.15)) }
                } else {
                    ForEach(0..<min(roomPhotos.count, 3), id: \.self) { index in
                        RoundedRectangle(cornerRadius: 28).fill(Color.white).frame(width: 280 - CGFloat(index * 15), height: 340)
                            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                            .overlay { RoundedRectangle(cornerRadius: 28).stroke(Color.black.opacity(0.05), lineWidth: 1) }
                            .offset(y: CGFloat(index * -16)).rotationEffect(.degrees(index == 0 ? 0 : (index == 1 ? -4 : 4))).zIndex(Double(4 - index))
                    }
                    
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.03)).aspectRatio(0.9, contentMode: .fit)
                            .overlay { Image(systemName: "photo.fill").font(.system(size: 32)).foregroundColor(.black.opacity(0.1)) }.padding(12)
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(roomPhotos.first?.user?.name ?? "myname").font(.UbuntuBold(size: 14)).foregroundColor(.black.opacity(0.8))
                                Text("Documented an unforgettable activity!").font(.Ubuntu(size: 11)).foregroundColor(.black.opacity(0.4)).lineLimit(1)
                            }
                            Spacer()
                            Text("😆").font(.system(size: 22))
                        }.padding(.horizontal, 16).padding(.bottom, 16)
                    }.frame(width: 280, height: 340).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 28)).shadow(color: .black.opacity(0.08), radius: 15, y: 10).zIndex(5)
                }
            }.frame(height: 380)
            
            Spacer()
            
            Button(action: {
                // الحفظ الفوري وإطلاق بث الإشارة للـ MainView للعودة للجذر وإقفال مسار الروم بالكامل
                NotificationCenter.default.post(name: NSNotification.Name("DismissRoomFlow"), object: nil)
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Text("Save Photos").font(.UbuntuBold(size: 20))
                    Image(systemName: "square.and.arrow.down").font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 58).background(Color(red: 0.18, green: 0.18, blue: 0.18)).clipShape(RoundedRectangle(cornerRadius: 99)).shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
            }
            .padding(.horizontal, 24).padding(.bottom, 24)
        }
        .background(Color("Backgroundcolor").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Room.self, User.self, Photo.self, configurations: config)
    let sampleRoom = Room(name: "Mission District Mural Hunt", code: "JSR-99X", category: "Creative", location: "Outdoor", maxPhotos: 9)
    let sampleUser = User(name: "Wteen")
    container.mainContext.insert(sampleRoom)
    container.mainContext.insert(sampleUser)
    
    return RoomSummary(room: sampleRoom)
        .modelContainer(container)
}
