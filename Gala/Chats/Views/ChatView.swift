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
    
    @ObservedObject var viewModel = ChatViewModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                header
                
                messageLog

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
            .padding(.horizontal)
            
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
    }
    
    var messageLog: some View {
        ScrollViewReader{ proxy in
            ScrollView(showsIndicators: false){
                ForEach(0...15, id:\.self){ i in
                    if i % 2 == 0 {
                        MessageView(message: "Hey I'm Suzy and i like fuk", fromMe: false)
                    } else {
                        MessageView(message: "Hey Suzy, I'm vaughn and i like to play hockey and baseball and shit", fromMe: true)
                    }
                }
                HStack { Spacer() }
                .frame(width: screenWidth, height: screenHeight * 0.001)
            }
            .onAppear{
                proxy.scrollTo(15)
            }
            .cornerRadius(20)
        }
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
                
                TextField("Start typing..", text: $viewModel.messageText, onCommit: {
                    viewModel.sendMessage(toUID: userChat!.uid)
                })
                    .foregroundColor(.black)
                    .padding(.horizontal)
            }
            .frame(height: screenWidth * 0.09)
            
            Button(action: {
                viewModel.sendMessage(toUID: userChat!.uid)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.buttonPrimary)
                        
                    Text("Send")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
            .disabled(viewModel.messageText.isEmpty)
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
