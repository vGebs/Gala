//
//  ConvoPreview.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct ConvoPreview: View {
    
    @ObservedObject var user: SmallUserViewModel
    @State var pressed = false
    
    @Binding var showChat: Bool
    
    @Binding var userChat: UserChat?
    
    init(id: String, showChat: Binding<Bool>, user: Binding<UserChat?>){
        self.user = SmallUserViewModel(uid: id)
        self._showChat = showChat
        self._userChat = user
    }
    
    var body: some View {
        HStack{
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .stroke()
                    .frame(width: screenWidth / 9, height: screenWidth / 9)
                    .foregroundColor(.blue)
                    .padding(.trailing)
                
                if user.img == nil {
                    Image(systemName: "person.fill.questionmark")
                        .foregroundColor(Color(.systemTeal))
                        .frame(width: screenWidth / 20, height: screenWidth / 20)
                        .padding(.trailing)
                    
                } else {
                    Image(uiImage: user.img!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth / 9.2, height: screenWidth / 9.2)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.trailing)
                }
            }
            
            VStack{
                Divider()
                Spacer()
                HStack {
                    Button(action: {
                        userChat = UserChat(name: user.profile!.name, uid: user.profile!.uid, location: user.city, bday: user.profile!.age, profileImg: user.img!)
                        showChat = true
                    }){
                        VStack {
                            HStack {
                                Text("\(user.profile?.name ?? ""), \(user.profile?.age.ageString() ?? "")")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "arrowtriangle.right")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.buttonPrimary)
                                
                                Text("Opened")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Image(systemName: "circlebadge.fill")
                                //.resizable()
                                    .font(.system(size: 5, weight: .regular, design: .rounded))
                                //.frame(width: 3, height: 3)
                                
                                Text("2h")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                Spacer()
                            }
                        }
                    }
                    
                    Button(action: {  }){
                        Image(systemName: "camera")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.buttonPrimary)
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .frame(width: screenWidth * 0.95, height: screenWidth / 9)
    }
}
