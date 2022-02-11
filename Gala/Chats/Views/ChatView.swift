//
//  ChatView.swift
//  Gala
//
//  Created by Vaughn on 2022-02-10.
//

import SwiftUI

struct ChatView: View {
    @Binding var showChat: Bool
    @State var chatText = ""
    @Binding var userChat: UserChat?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                header
                
                ScrollView(showsIndicators: false){
                    ForEach(0...15, id:\.self){ i in
                        if i % 2 == 0 {
                            HStack {
                                ZStack {
                                    Text("Hello, im Lucy and i like to fuck")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 7)
                                .background(Color.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(maxWidth: screenWidth * 0.7)
                                
                                Spacer()

                            }
                        } else {
                            HStack {
                                Spacer()
                                
                                ZStack {
                                    Text("Hello, im vaughn whats up aw d aw d awd aw da wd")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 7)
                                .background(Color.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(maxWidth: screenWidth * 0.7)
                            }
                        }
                        
                    }
                    HStack { Spacer() }
                }
                .cornerRadius(20)
                
                footer
            }
        }
        .onTapGesture {
            self.endEditing()
        }
    }
    
    var header: some View {
        HStack {
            ZStack{
                if userChat?.profileImg != nil {
                    Image(uiImage: userChat!.profileImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth / 9.2, height: screenWidth / 9.2)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                
                RoundedRectangle(cornerRadius: 5)
                    .stroke()
                    .foregroundColor(.buttonPrimary)
                    .frame(width: screenWidth / 9.2, height: screenWidth / 9.2)
            }
            .padding(.trailing)
            
            VStack(alignment: .leading) {
                Text("\(userChat!.name), \(userChat!.bday.ageString())")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("\(userChat!.location)")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
            
            Button(action: { self.showChat = false }){
                Image(systemName: "arrow.down")
            }
            .padding(.trailing)
        }
        .frame(height: screenWidth * 0.11)
        .padding(.top)
        //.padding(.horizontal)
    }
    
    var footer: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.buttonPrimary)
            }
            
            ZStack {
                Capsule()
                    .foregroundColor(.white)
                
                TextField("Start typing..", text: $chatText)
                    .padding(.horizontal)
            }
            .frame(height: screenWidth * 0.09)
            
            Button(action: {}) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.buttonPrimary)
                        
                    Text("Send")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
            .frame(width: screenWidth * 0.15, height: screenWidth * 0.09)
        }
        .padding(.bottom)
        .padding(.horizontal)
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
