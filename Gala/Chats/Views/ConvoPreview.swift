//
//  ConvoPreview.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI
import OrderedCollections
import CoreLocation

struct ConvoPreview: View {
    
    //@ObservedObject var user: SmallUserViewModel
    @State var pressed = false
    
    @Binding var showChat: Bool
    
    @Binding var userChat: UserChat?
    @Binding var messages: OrderedDictionary<String, [Message]>
    var timeMatched: Date
    @Binding var timeMatchedBinding: Date?
    
    @State var showProfile = false
    @ObservedObject var chatsViewModel: ChatsViewModel
    var ucMatch: MatchedUserCore
    
    init(ucMatch: MatchedUserCore, showChat: Binding<Bool>, user: Binding<UserChat?>, messages: Binding<OrderedDictionary<String, [Message]>>, timeMatchedBinding: Binding<Date?>, chatsViewModel: ChatsViewModel){
        self.ucMatch = ucMatch
        self._showChat = showChat
        self._userChat = user
        self._messages = messages
        self.timeMatched = ucMatch.timeMatched
        self._timeMatchedBinding = timeMatchedBinding
        self.chatsViewModel = chatsViewModel
    }
    
    var body: some View {
        HStack{
            Button(action: { self.showProfile = true }){
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke()
                        .frame(width: screenWidth / 9, height: screenWidth / 9)
                        .foregroundColor(.blue)
                        .padding(.trailing)
                    
                    if ucMatch.profileImg == nil {
                        Image(systemName: "person.fill.questionmark")
                            .foregroundColor(Color(.systemTeal))
                            .frame(width: screenWidth / 20, height: screenWidth / 20)
                            .padding(.trailing)
                        
                    } else {
                        Image(uiImage: ucMatch.profileImg!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth / 9.2, height: screenWidth / 9.2)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding(.trailing)
                    }
                }
            }
            
            VStack{
                Divider()
                Spacer()
                HStack {
                    Button(action: {
                        if let img = ucMatch.profileImg {
                            userChat = UserChat(name: ucMatch.uc.name, uid: ucMatch.uc.uid, bday: ucMatch.uc.age, profileImg: img)
                        } else {
                            userChat = UserChat(name: ucMatch.uc.name, uid: ucMatch.uc.uid, bday: ucMatch.uc.age, profileImg: nil)
                        }
                        
                        timeMatchedBinding = timeMatched
                        showChat = true
                        
                        //open message
                        // if the last message is not already opened and was not sent by me
                        if let _ = messages[ucMatch.uc.uid]{
                            if !messages[ucMatch.uc.uid]![messages[ucMatch.uc.uid]!.count - 1].opened && (messages[ucMatch.uc.uid]![messages[ucMatch.uc.uid]!.count - 1].fromID != AuthService.shared.currentUser?.uid) {
                                //messages[user.profile!.uid]![messages[user.profile!.uid]!.count - 1].opened = true
                                chatsViewModel.openMessage(message: messages[ucMatch.uc.uid]![messages[ucMatch.uc.uid]!.count - 1])
                            }
                        }
                    }){
                        VStack {
                            HStack {
                                Text("\(ucMatch.uc.name), \(ucMatch.uc.age.ageString())")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            if messages[ucMatch.uc.uid] == nil {
                                HStack {
                                    Image(systemName: "figure.stand.line.dotted.figure.stand")
                                        .font(.system(size: 12, weight: .regular, design: .rounded))
                                        .foregroundColor(.buttonPrimary)
                                    
                                    Text("Matched \(secondsToHoursMinutesSeconds(Int(timeMatched.timeIntervalSinceNow)))")
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            } else {
                                HStack {
                                    //I sent a message
                                    if messages[ucMatch.uc.uid]![messages[ucMatch.uc.uid]!.count - 1].fromID == AuthService.shared.currentUser?.uid {
                                        
                                        if messages[ucMatch.uc.uid]![messages[ucMatch.uc.uid]!.count - 1].opened {
                                            
                                            Image(systemName: "arrowtriangle.right")
                                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                                .foregroundColor(.buttonPrimary)
                                            Text("Opened")
                                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                                .foregroundColor(.primary)
                                            Image(systemName: "circlebadge.fill")
                                                .font(.system(size: 5, weight: .regular, design: .rounded))
                                            Text(secondsToHoursMinutesSeconds_(Int(messages[ucMatch.uc.uid]![messages[ucMatch.uc.uid]!.count - 1].time.timeIntervalSinceNow)))
                                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                            
                                        } else {
                                            Image(systemName: "arrowtriangle.right.fill")
                                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                                .foregroundColor(.buttonPrimary)
                                            Text("Sent")
                                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                                .foregroundColor(.primary)
                                            Image(systemName: "circlebadge.fill")
                                                .font(.system(size: 5, weight: .regular, design: .rounded))
                                            Text(secondsToHoursMinutesSeconds_(Int(messages[ucMatch.uc.uid]![messages[ucMatch.uc.uid]!.count - 1].time.timeIntervalSinceNow)))
                                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                        }
                                    } else {
                                        //i recieved a message
                                        if messages[ucMatch.uc.uid]![messages[ucMatch.uc.uid]!.count - 1].opened {
                                            Image(systemName: "bubble.left")
                                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                                .foregroundColor(.buttonPrimary)
                                            Text("Opened")
                                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                                .foregroundColor(.primary)
                                            Image(systemName: "circlebadge.fill")
                                                .font(.system(size: 5, weight: .regular, design: .rounded))
                                            Text(secondsToHoursMinutesSeconds_(Int(messages[ucMatch.uc.uid]![messages[ucMatch.uc.uid]!.count - 1].time.timeIntervalSinceNow)))
                                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                        } else {
                                            Image(systemName: "bubble.left.fill")
                                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                                .foregroundColor(.buttonPrimary)
                                            Text("New message")
                                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                                .foregroundColor(.primary)
                                            Image(systemName: "circlebadge.fill")
                                                .font(.system(size: 5, weight: .regular, design: .rounded))
                                            Text(secondsToHoursMinutesSeconds_(Int(messages[ucMatch.uc.uid]![messages[ucMatch.uc.uid]!.count - 1].time.timeIntervalSinceNow)))
                                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                        }
                                    }
                                    
                                    Spacer()
                                }
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
        .sheet(isPresented: $showProfile, content: {
            ProfileMainView(viewModel: ProfileViewModel(mode: .otherAccount, uid: ucMatch.uc.uid), showProfile: $showProfile)
        })
        .frame(width: screenWidth * 0.95, height: screenWidth / 9)
    }
    
    func secondsToHoursMinutesSeconds_(_ seconds: Int) -> String { //(Int, Int, Int)
        
        if abs(((seconds % 3600) / 60)) == 0 {
            let secondString = "\(abs((seconds % 3600) / 60))s"
            return secondString
        } else if abs((seconds / 3600)) == 0 {
            let minuteString = "\(abs((seconds % 3600) / 60))m"
            return minuteString
        } else if abs(seconds / 3600) < 24{
            let hourString = "\(abs(seconds / 3600))h"
            return hourString
        } else {
            let dayString = "\(abs(seconds / 86400))d"
            return dayString
        }
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> String { //(Int, Int, Int)
        
        if abs(((seconds % 3600) / 60)) == 0 {
            let secondString = "\(abs((seconds % 3600) / 60)) seconds ago"
            return secondString
        } else if abs((seconds / 3600)) == 0 {
            let minuteString = "\(abs((seconds % 3600) / 60)) minutes ago"
            return minuteString
        } else if abs(seconds / 3600) < 24{
            let hourString = "\(abs(seconds / 3600)) hours ago"
            return hourString
        } else {
            let dayString = "\(abs(seconds / 86400)) days ago"
            return dayString
        }
    }
}
