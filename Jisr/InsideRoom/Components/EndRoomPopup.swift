//
//  EndRoomPopup.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 04/12/1447 AH.
//

//
//  EndRoomPopup.swift
//  Jisr
//
//  Created by Wteen Alghamdy on 01/12/1447 AH.
//

import SwiftUI

struct EndRoomPopup: View {
    @Binding var isPresented: Bool
    let onConfirmEnd: () -> Void
    
    var body: some View {
        ZStack {
            // الخلفية الشفافة الداكنة للـ Popup
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            // كارد التنبيه المصمم بالملي حسب الفيقما
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("Do you want to end\nthe room")
                        .font(.UbuntuBold(size: 22))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Text("You can not undo this action")
                        .font(.Ubuntu(size: 15))
                        .foregroundColor(.black.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 10)
                
                VStack(spacing: 12) {
                    // زر التأكيد والإنهاء الفعلي
                    Button(action: {
                        isPresented = false
                        onConfirmEnd()
                    }) {
                        Text("End Room")
                            .font(.UbuntuBold(size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(red: 0.18, green: 0.18, blue: 0.18)) // الرمادي الداكن المعتمد في الفيقما للإنهاء
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                    }
                    
                    // زر التراجع والإلغاء
                    Button(action: { isPresented = false }) {
                        Text("cancel")
                            .font(.UbuntuBold(size: 18))
                            .foregroundColor(.black.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color("fieldColor")) // لون دافئ هادئ للإلغاء
                            .clipShape(RoundedRectangle(cornerRadius: 99))
                    }
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
    EndRoomPopup(isPresented: .constant(true), onConfirmEnd: {})
}
