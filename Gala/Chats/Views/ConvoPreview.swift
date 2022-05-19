//
//  ConvoPreview.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI
import OrderedCollections
import CoreLocation

//Message Precedence algo:
///
//If there is unOpenedSnapsToMe
//    show unOpenedSnapToMeView     (1)
//
//If there is unOpenedMessagesToMe && noUnOpenedSnapsToMe
//    show unOpenedMessageToMeView  (2)
//
//If there is noUnOpenedMessagesToMe && noUnOpenedSnapsToMe
//
//    compare the most recent chat or snap
//
//    if it is a snap
//        if snap.openedDate == nil
//            if it is from me
//                show UnOpenedSnapFromMe   (3)
//        if snap.openedDate != nil
//            if it is from me
//                show openedSnapFromMe     (4)
//            if it is to me
//                show openedSnapToMe       (5)
//
//    if it is a chat
//        if message.openedDate == nil
//            if it is from me
//                show unOpenedMessageFromMe (6)
//
//        if message.openedDate != nil
//            if it is from me
//                show openedMessageFromMe   (7)
//            if it is to me
//                show openedMessageToMe     (8)
//
//If there is no snaps and no messages
//    show match date

//Message
//    - to me
//        - opened (8)
//        - unOpened (2)
//    - from me
//        -opened (7)
//        - unopened (6)
//Snap
//    - to me
//        - opened (5)
//        - unOpened (1)
//    - from me
//        -opened (4)
//        - unopened (3)

struct ConvoPreview: View {
        
    @Binding var showChat: Bool
    
    @Binding var userChat: UserChat
    @Binding var messages: OrderedDictionary<String, [Message]>
    var timeMatched: Date
    @Binding var timeMatchedBinding: Date?
    
    @State var showProfile = false
    @ObservedObject var chatsViewModel: ChatsViewModel
    var ucMatch: MatchedUserCore
    
    @State var showSnapView = false
    
    init(ucMatch: MatchedUserCore, showChat: Binding<Bool>, user: Binding<UserChat>, messages: Binding<OrderedDictionary<String, [Message]>>, timeMatchedBinding: Binding<Date?>, chatsViewModel: ChatsViewModel){
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
                                                
                        switch chatsViewModel.convoPressed(for: ucMatch) {
                            
                        case .openSnap:
                            self.timeMatchedBinding = ucMatch.timeMatched
                            self.showSnapView = true
                        case .viewChat:
                            self.timeMatchedBinding = ucMatch.timeMatched
                            self.showChat = true
                        }
                        
                    }){
                        VStack {
                            HStack {
                                Text("\(ucMatch.uc.userBasic.name), \(ucMatch.uc.userBasic.birthdate.ageString())")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            switch chatsViewModel.convoReceipt(for: ucMatch.uc.userBasic.uid) {
                            case .unOpenedSnapToMe:
                                unopenedSnapToMeView
                                
                            case .unOpenedMessageToMe:
                                unopenedMessageToMeView
                                
                            case .unOpenedSnapFromMe:
                                unopenedSnapFromMeView
                                
                            case .openedSnapFromMe:
                                openedSnapFromMeView
                                
                            case .openedSnapToMe:
                                openedSnapToMeView
                                
                            case .unOpenedMessageFromMe:
                                unopenedMessageFromMeView
                                
                            case .openedMessageFromMe:
                                openedMessageFromMeView
                                
                            case .openedMessageToMe:
                                openedMessageToMeView
                                
                            case .newMatch:
                                newMatchView
                            }
                        }
                    }
                    
                    let uid = ucMatch.uc.userBasic.uid
                    //if we have an unopenedsnap from
                    if chatsViewModel.snaps[uid] != nil {
                        if chatsViewModel.snaps[uid]![chatsViewModel.snaps[uid]!.count - 1].openedDate == nil && chatsViewModel.snaps[uid]![chatsViewModel.snaps[uid]!.count - 1].fromID != AuthService.shared.currentUser!.uid{
                            Button(action: {
                                if let _ = messages[uid]{
                                    //we just need to check ucMatch when its a chat, not a snap
                                    if let img = ucMatch.profileImg {
                                        userChat = UserChat(
                                            name: ucMatch.uc.userBasic.name,
                                            uid: ucMatch.uc.userBasic.uid,
                                            location: Coordinate(
                                                lat: ucMatch.uc.searchRadiusComponents.coordinate.lat,
                                                lng: ucMatch.uc.searchRadiusComponents.coordinate.lng
                                            ),
                                            bday: ucMatch.uc.userBasic.birthdate,
                                            profileImg: img
                                        )
                                    } else {
                                        userChat = UserChat(
                                            name: ucMatch.uc.userBasic.name,
                                            uid: ucMatch.uc.userBasic.uid,
                                            location: Coordinate(
                                                lat: ucMatch.uc.searchRadiusComponents.coordinate.lat,
                                                lng: ucMatch.uc.searchRadiusComponents.coordinate.lng
                                            ),
                                            bday: ucMatch.uc.userBasic.birthdate,
                                            profileImg: nil
                                        )
                                    }
                                    
                                    chatsViewModel.getTempMessages(uid: ucMatch.uc.userBasic.uid)
                                    
                                    timeMatchedBinding = timeMatched
                                    showChat = true
                                    //open message
                                    // if the last message is not already opened and was not sent by me
                                    
                                    if messages[uid]![messages[uid]!.count - 1].openedDate == nil && (messages[uid]![messages[uid]!.count - 1].fromID != AuthService.shared.currentUser?.uid) {

                                        timeMatchedBinding = timeMatched
                                        showChat = true
                                        
                                        chatsViewModel.openMessage(message: messages[uid]![messages[uid]!.count - 1])
                                    }
                                } else {
                                    if let img = ucMatch.profileImg {
                                        userChat = UserChat(
                                            name: ucMatch.uc.userBasic.name,
                                            uid: uid,
                                            location: Coordinate(
                                                lat: ucMatch.uc.searchRadiusComponents.coordinate.lat,
                                                lng: ucMatch.uc.searchRadiusComponents.coordinate.lng
                                            ),
                                            bday: ucMatch.uc.userBasic.birthdate,
                                            profileImg: img
                                        )
                                    } else {
                                        userChat = UserChat(
                                            name: ucMatch.uc.userBasic.name,
                                            uid: uid,
                                            location: Coordinate(
                                                lat: ucMatch.uc.searchRadiusComponents.coordinate.lat,
                                                lng: ucMatch.uc.searchRadiusComponents.coordinate.lng
                                            ),
                                            bday: ucMatch.uc.userBasic.birthdate,
                                            profileImg: nil
                                        )
                                    }
                                    
                                    chatsViewModel.getTempMessages(uid: ucMatch.uc.userBasic.uid)
                                    
                                    timeMatchedBinding = timeMatched
                                    showChat = true
                                }
                            }){
                                Image(systemName: "message.fill")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(.buttonPrimary)
                            }
                        }
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .sheet(isPresented: $showSnapView, content: {
            SnapView(show: $showSnapView, snapViewModel: chatsViewModel, uid: userChat.uid, snap: $chatsViewModel.tempSnap)
        })
        .sheet(isPresented: $showProfile, content: {
            ProfileMainView(viewModel: ProfileViewModel(mode: .otherAccount, uid: ucMatch.uc.userBasic.uid), showProfile: $showProfile)
        })
        .frame(width: screenWidth * 0.95, height: screenWidth / 9)
    }
    
    var unopenedSnapFromMeView: some View {
        HStack {
            Image(systemName: "arrowtriangle.right.fill")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text("Snap Sent")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.accent)
            Image(systemName: "circlebadge.fill")
                .font(.system(size: 5, weight: .regular, design: .rounded))
            Text(secondsToHoursMinutesSeconds_(Int(chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].snapID_timestamp.timeIntervalSinceNow)))
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.accent)
            Spacer()
        }
    }
    
    var unopenedSnapToMeView: some View {
        HStack {
            Image(systemName: "map.fill")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text("New Snap")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.accent)
            Image(systemName: "circlebadge.fill")
                .font(.system(size: 5, weight: .regular, design: .rounded))
            Text(secondsToHoursMinutesSeconds_(Int(chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].snapID_timestamp.timeIntervalSinceNow)))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.accent)
            Spacer()
        }
    }
    
    var openedSnapFromMeView: some View {
        HStack {
            Image(systemName: "arrowtriangle.right")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            Text("Snap Opened")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.accent)
            Image(systemName: "circlebadge.fill")
                .font(.system(size: 5, weight: .regular, design: .rounded))
            Text(secondsToHoursMinutesSeconds_(Int(chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].snapID_timestamp.timeIntervalSinceNow)))
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.accent)
            Spacer()
        }
    }
    
    var openedSnapToMeView: some View {
        HStack {
            Image(systemName: "map")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            Text("Received")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.accent)
            Image(systemName: "circlebadge.fill")
                .font(.system(size: 5, weight: .regular, design: .rounded))
            Text(secondsToHoursMinutesSeconds_(Int(chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].snapID_timestamp.timeIntervalSinceNow)))
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.accent)
            Spacer()
        }
    }
    
    var unopenedMessageFromMeView: some View {
        HStack {
            Image(systemName: "arrowtriangle.right.fill")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.buttonPrimary)
            Text("Sent")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.accent)
            Image(systemName: "circlebadge.fill")
                .font(.system(size: 5, weight: .regular, design: .rounded))
            Text(secondsToHoursMinutesSeconds_(Int(messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].time.timeIntervalSinceNow)))
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.accent)
            Spacer()
        }
    }
    
    var unopenedMessageToMeView: some View {
        HStack {
            Image(systemName: "bubble.left.fill")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.buttonPrimary)
            Text("Message")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.accent)
            Image(systemName: "circlebadge.fill")
                .font(.system(size: 5, weight: .regular, design: .rounded))
            Text(secondsToHoursMinutesSeconds_(Int(messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].time.timeIntervalSinceNow)))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.accent)
            Spacer()
        }
    }
    
    var openedMessageFromMeView: some View {
        HStack {
            Image(systemName: "arrowtriangle.right")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.buttonPrimary)
            Text("Opened")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.accent)
            Image(systemName: "circlebadge.fill")
                .font(.system(size: 5, weight: .regular, design: .rounded))
            Text(secondsToHoursMinutesSeconds_(Int(messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].time.timeIntervalSinceNow)))
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.accent)
            Spacer()
        }
    }
    
    var openedMessageToMeView: some View {
        HStack {
            Image(systemName: "bubble.left")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.buttonPrimary)
            Text("Received")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.accent)
            Image(systemName: "circlebadge.fill")
                .font(.system(size: 5, weight: .regular, design: .rounded))
            Text(secondsToHoursMinutesSeconds_(Int(messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].time.timeIntervalSinceNow)))
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.accent)
            Spacer()
        }
    }
    
    var newMatchView: some View {
        HStack {
            Image(systemName: "figure.stand.line.dotted.figure.stand")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.buttonPrimary)
            Text("Matched \(secondsToHoursMinutesSeconds(Int(timeMatched.timeIntervalSinceNow)))")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
        }
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
