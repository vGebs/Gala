//
//  ChatView.swift
//  Gala
//
//  Created by Vaughn on 2022-02-10.
//

import SwiftUI
import OrderedCollections

struct ChatView: View {
    @Binding var showChat: Bool
    @State var chatText = ""
    @Binding var userChat: UserChat?
    
    @ObservedObject var viewModel = ChatViewModel()
    @Binding var messages: OrderedDictionary<String, [Message]>
    @Binding var timeMatched: Date?
    
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
            
            Button(action: {
                self.showChat = false
                //self.timeMatched = nil
                //self.userChat = nil
            }){
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
                macthedDateView
                if messages[userChat!.uid] != nil {
                    ForEach(messages[userChat!.uid]!){ message in
                        if message.toID == AuthService.shared.currentUser!.uid {
                            MessageView(message: message.message, fromMe: false)
                        } else {
                            MessageView(message: message.message, fromMe: true)
                        }
                    }
                }
                HStack { Spacer() }
                .frame(width: screenWidth, height: screenHeight * 0.001)
            }
            .onAppear{
                if messages[userChat!.uid] != nil {
                    proxy.scrollTo(messages[userChat!.uid]!.count)
                }
            }
            .cornerRadius(20)
        }
    }
    
    var macthedDateView: some View {
        HStack {
            Image(systemName: "figure.stand.line.dotted.figure.stand")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.buttonPrimary)
            
            Text("Matched \(secondsToHoursMinutesSeconds(Int(timeMatched!.timeIntervalSinceNow)))")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(RoundedRectangle(cornerRadius: 5).foregroundColor(.accent))
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
                
                TextField("", text: $viewModel.messageText, onCommit: {
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
