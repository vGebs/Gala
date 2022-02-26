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
    @Binding var snaps: OrderedDictionary<String, [Snap]>
    @Binding var timeMatched: Date?
    
    @State var showProfile = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                header
                
                messageLog

                footer
            }
        }
        .sheet(isPresented: $showProfile, content: {
            ProfileMainView(viewModel: ProfileViewModel(mode: .otherAccount, uid: userChat!.uid), showProfile: $showProfile)
        })
        .onTapGesture {
            self.endEditing()
        }
    }
    
    var header: some View {
        HStack {
            Button(action: {
                self.showProfile = true
            }) {
                ZStack{
                    if userChat?.profileImg != nil {
                        Image(uiImage: userChat!.profileImg!)
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
                    HStack{
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.buttonPrimary)
                        
                        Text("Poop Town")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                }
            }
            
            Spacer()
            
            Button(action: {
                self.showChat = false
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
                                .padding(.leading, 3)
                        } else {
                            MessageView(message: message.message, fromMe: true)
                                .padding(.trailing, 3)
                        }
                    }
                }
                
                if snaps[userChat!.uid] != nil {
                    ForEach(snaps[userChat!.uid]!){ snap in
                        if snap.openedDate == nil && snap.fromID != AuthService.shared.currentUser!.uid{
                            SnapMessageView(snap: snap)
                                .padding(.leading, 3)
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
            
            Text("Matched \(secondsToHoursMinutesSeconds_(Int(timeMatched!.timeIntervalSinceNow)))")
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
    
    func secondsToHoursMinutesSeconds_(_ seconds: Int) -> String { //(Int, Int, Int)
        
        //60 = 1 minute
        //3600 = 1 hour
        //86400 = 1 day
        //604800 = 1 week
        
        if abs(((seconds % 3600) / 60)) == 0 {
            let secondString = "\(abs((seconds % 3600) / 60))s ago"
            return secondString
        } else if abs((seconds / 3600)) == 0 {
            let minuteString = "\(abs((seconds % 3600) / 60))min ago"
            return minuteString
        } else if abs(seconds / 3600) < 24{
            if abs(seconds / 3600) == 1 {
                let hourString = "\(abs(seconds / 3600)) hour ago"
                return hourString
            } else {
                let hourString = "\(abs(seconds / 3600)) hours ago"
                return hourString
            }
        } else if abs(seconds / 86400) < 7{
            if abs(seconds / 86400) == 1 {
                let dayString = "\(abs(seconds / 86400)) day ago"
                return dayString
            } else {
                let dayString = "\(abs(seconds / 86400)) days ago"
                return dayString
            }
        } else {
            if (abs(seconds / 604800) == 1) {
                let weekString = "\(abs(seconds / 604800)) week ago"
                return weekString
            } else {
                let weekString = "\(abs(seconds / 604800)) weeks ago"
                return weekString
            }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
