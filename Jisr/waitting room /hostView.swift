//
//  host.swift
//  Jisr
//
//  Created by Wed Ahmed Alasiri on 12/05/2026.
// in ai  لازم احط خانه للاسم المشن و دسكربشن عنها لازم
// add Dynamic type in accessibility

//
//  host.swift
//  Jisr
//
//  Created by Wed Ahmed Alasiri on 12/05/2026.
// in ai  لازم احط خانه للاسم المشن و دسكربشن عنها لازم
// add Dynamic type in accessibility🔴
// غيري الخط حق المودل
//اربطي الصفحه ذي بالصفحه وتين الكاميرا
//تاكدي من انه سويتي نفس الشي للقست
// اتاكد من الداتا بيس 
import SwiftUI
import CoreML

struct WaitingRoomView: View {
    
    
    @Binding var waitingDestination: WaitingDestination?

    @State private var copied = false
   
    var isStarted: Bool = false
    
    let room: Room

    @State private var missionTitle = ""
    @State private var missionDescription = ""
    var backgroundImageName: String {
        switch room.category {
        case "Cognitive": return "bluebg"
        case "Physical":  return "greenbg"
        default:          return "yellowbg"
        }
    }
    
    var backgroundForBtn: String {
        switch room.category {
        case "Cognitive": return "backbtnblue"
        case "Physical":  return "blackbtngreen"
        default:          return "back bg"
        }
    }
    
    
    var body: some View {
        ZStack(alignment: .bottom) { // جعل العناصر تترتب فوق بعضها
            
            // 1. الخلفية الثابتة
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // 2. المحتوى الأساسي
            VStack {
                
                
                // MARK: Header & Mission & Code (العناصر الثابتة في الأعلى)
                VStack {
                    
                    // الهيدر
                    HStack {
                        Button(action: {
                            waitingDestination = nil
                        }) {
                            Image(systemName: "chevron.left")
                            
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Text(room.name)
                            .font(.UbuntuBold(size: 22))

//                            .font(.system(size: 22, weight: .bold))
                        Spacer()
                        Color.clear.frame(width: 24)
                    }
                    //                    .padding(.top, 10)
                    .offset(y:-30)
                    
                    // بطاقة المهمة
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack(alignment: .top) {

                              Text(missionTitle)
                                .font(.UbuntuBold(size: 20))
//                                 .font(.system(size: 20, weight: .medium))
                                 .foregroundColor(.black.opacity(0.75))

                            Spacer()
                                Button(action: {
                                    generateMission()
                                    }) {
                                        Image(systemName: "arrow.trianglehead.2.clockwise")
                                            .font(.system(size: 20))
                                            .foregroundColor(.black.opacity(0.75))
                                        }
                                    }

                                    Text(missionDescription)
                                          .font(.UbuntuBold(size: 14))
//                                        .font(.system(size: 14))
                                        .foregroundColor(.black.opacity(0.7))
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(red: 248/255,
                                                          green: 242/255,
                                                          blue: 230/255))
                                        .cornerRadius(18)

                                }
                                .padding(16)
                                .background(Color(red: 244/255, green: 242/255, blue: 237/255))
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.black.opacity(0.7), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.4), radius: 0, x: 0, y: 3)
                                .padding(.horizontal, -10)
                     //         .padding(.top, 22)
                                .offset(y: -120)
                    
                    // زر النسخ (نهاية العناصر الثابتة)
                    HStack {
                        Label("5", systemImage: "person.fill")
//                        Spacer()
//                            .offset(x:-10)
                        
                        HStack {

                            Text(room.code)
                                .foregroundColor(.gray)

                            Button(action: {

                                UIPasteboard.general.string = room.code
                                withAnimation {
                                    copied = true
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {

                                    withAnimation {
                                        copied = false
                                    }
                                }

                            }) {

                                Image(systemName: copied ? "checkmark" : "document.on.document")
                                    .foregroundColor(copied ? .green : .gray)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                        }
                        .padding(.horizontal, 55)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(20)
                        
                        
                        ShareLink(
                            item: """
                            Join my room in Jisr 
                            
                            Room Code: \(room.code)
                            
                            Mission:
                            Mission District Mural Hunt
                            
                            Go to Mission District and each photograph the mural that moved you the most
                            """
                        ) {
                            Image(systemName: "square.and.arrow.up")
                                .padding(8)
                                .foregroundColor(.black)
                        }
                    }
                    .offset(y:-100)
                    
                }
                .padding(.horizontal, 25)
                
                
                // MARK: ScrollView (تبدأ من هنا وتأخذ باقي الشاشة)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        // قائمة المستخدمين
                        UserCard(name: "ess", image: "person1")
                        UserCard(name: "ayad.200", image: "person1")
                        UserCard(name: "charlie alixander", image: "person1")
                        UserCard(name: "lionnn.15", image: "person1")
                        UserCard(name: "wiliam better.2", image: "person1")
                        UserCard(name: "New Player 1", image: "person1")
                        UserCard(name: "New Player 2", image: "person1")
                        
                        // مساحة إضافية في نهاية السكرول عشان آخر اسم ما يغطي عليه زر الـ Start
                        Color.clear.frame(height: 30)
                    }
//                    .padding(.top, 20)
                    .padding(.horizontal)
                    .padding(.vertical,40)

                }
                .frame(maxWidth: .infinity, alignment: .center)
                .offset(y:-90)
                
            }
            
            // 3. زر Start الثابت (في طبقة أعلى ZStack)
            VStack {
                ZStack(alignment: .bottom) {
                    
                    // 1. الصورة اللي تبيها تكون خلفية للزر
                    Image(backgroundForBtn) // تأكد من اسم الصورة عندك
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160) // ارتفاع المنطقة اللي تغطي السكرول من تحت
                        .clipped()
//                    // القناع هو اللي يسوي حركة التلاشي (Fade)
//                        .mask(
//                            LinearGradient(
//                                gradient: Gradient(colors: [.clear, .black]), // من شفاف إلى ظاهر
//                                startPoint: .top,
//                                endPoint: .bottom
//                            )
//                        )
//                        .offset(y:-30)
                    
                    // 2. زر البدء
                    Button(action: {
                        room.missionTitle = missionTitle
                           room.missionDescription = missionDescription

                           waitingDestination = .camera
                    }) {
                        Text("Start")
                            .font(.UbuntuBold(size: 24))
//                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 220, height: 65)
                            .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                            .cornerRadius(35)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom, 40) // ارفعه شوي عن الحافة السفلية
                }
                .ignoresSafeArea() // يخلي التدرج يوصل لآخر الشاشة
            }
        }.navigationBarHidden(true)
        
        
        .onAppear {
            generateMission()
        }
    }
    func generateMission() {
        do {
            let config = MLModelConfiguration()
            let model = try jisr_test_1(configuration: config)
            
            let output = try model.prediction(
                Category: room.category,
                Location_Type: room.location
            )
            
            let availablePrompts = Array(output.PromptProbability.keys)
            let chosenPrompt = availablePrompts.randomElement() ?? output.Prompt
            
            // Format is: "Mission Title (Description text here)"
            if let openParen = chosenPrompt.firstIndex(of: "("),
               let closeParen = chosenPrompt.lastIndex(of: ")") {
//                
//                missionTitle = String(chosenPrompt[..<openParen])
//                    .trimmingCharacters(in: .whitespaces)
//                
//                let descStart = chosenPrompt.index(after: openParen)
//                missionDescription = String(chosenPrompt[descStart..<closeParen])
//                    .trimmingCharacters(in: .whitespaces)
                let title = String(chosenPrompt[..<openParen])
                    .trimmingCharacters(in: .whitespaces)

                let descStart = chosenPrompt.index(after: openParen)
                let description = String(chosenPrompt[descStart..<closeParen])
                    .trimmingCharacters(in: .whitespaces)

                missionTitle = title
                missionDescription = description

                room.missionTitle = title
                room.missionDescription = description
                
            } else {
                // Fallback if format is unexpected
                missionTitle = "Mission"
                missionDescription = chosenPrompt
            }
            
        } catch {
            missionDescription = "Could not load mission."
            missionTitle = "Mission"
            print(error.localizedDescription)
        }
    }
    
    // كرت المستخدم (نفسه بدون تغيير)
    struct UserCard: View {
        
        let name: String
        let image: String

        var body: some View {

            HStack(spacing: 15) {

                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .offset(x:-10)

                Spacer()
                Text(name)
                    .font(.UbuntuBold(size: 18))
//                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.trailing, 60) // ← يعطي مساحة بعد الاسم

            }
            .padding(.horizontal, 18)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.6))
            .cornerRadius(45)
            .fixedSize() // ✨ هذا المهم
        }
    }
}
#Preview {
    
    let previewRoom = Room(
        name: "Creative Room",
        code: "ABC-123",
        category: "Creative",
        location: "Outdoor",
        maxPhotos: 5
    )
    
    WaitingRoomView(
            waitingDestination: .constant(nil),
            room: previewRoom
        )
}
