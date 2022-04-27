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
        
    @Binding var showChat: Bool
    
    @Binding var userChat: UserChat?
    @Binding var messages: OrderedDictionary<String, [Message]>
    var timeMatched: Date
    @Binding var timeMatchedBinding: Date?
    
    @State var showProfile = false
    @ObservedObject var chatsViewModel: ChatsViewModel
    var ucMatch: MatchedUserCore
    
    @State var showSnapView = false
    
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
                        
                        let uid = ucMatch.uc.userBasic.uid
                        
                        if let _ = chatsViewModel.snaps[uid] {
                            //open snap
                            // if the last snap is not already opened and was not sent by me
                            
                            //if there is a snap that is not opened, open the snap but not the ChatView
                            //
                            if chatsViewModel.snaps[uid]![chatsViewModel.snaps[uid]!.count - 1].openedDate == nil && chatsViewModel.snaps[uid]![chatsViewModel.snaps[uid]!.count - 1].fromID != AuthService.shared.currentUser!.uid {
                                
                                //Show SnapView
                                userChat = UserChat(
                                    name: ucMatch.uc.userBasic.name,
                                    uid: uid,
                                    location:
                                        Coordinate(
                                            lat: ucMatch.uc.searchRadiusComponents.coordinate.lat,
                                            lng: ucMatch.uc.searchRadiusComponents.coordinate.lng
                                        ),
                                    bday: ucMatch.uc.userBasic.birthdate,
                                    profileImg: nil
                                )
                                
                                showSnapView = true
                                
                            } else if chatsViewModel.snaps[uid]![chatsViewModel.snaps[uid]!.count - 1].openedDate == nil && chatsViewModel.snaps[uid]![chatsViewModel.snaps[uid]!.count - 1].fromID == AuthService.shared.currentUser!.uid {
                                //we sent a snap
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
                                
                            } else if chatsViewModel.snaps[uid]![chatsViewModel.snaps[uid]!.count - 1].openedDate != nil && chatsViewModel.snaps[uid]![chatsViewModel.snaps[uid]!.count - 1].fromID != AuthService.shared.currentUser!.uid {
                                //we opened someones snap
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
                            } else {
                                if let _ = messages[ucMatch.uc.userBasic.uid]{
                                    //we just need to check ucMatch when its a chat, not a snap
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
                                    //open message
                                    // if the last message is not already opened and was not sent by me
                                    
                                    if messages[uid]![messages[uid]!.count - 1].openedDate == nil && (messages[uid]![messages[uid]!.count - 1].fromID != AuthService.shared.currentUser?.uid) {
                                        //messages[user.profile!.uid]![messages[user.profile!.uid]!.count - 1].opened = true
                                        
                                        chatsViewModel.openMessage(message: messages[uid]![messages[uid]!.count - 1])
                                    }
                                }
                            } 
                        } else if let _ = messages[uid]{
                            //we just need to check ucMatch when its a chat, not a snap
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
                        VStack {
                            HStack {
                                Text("\(ucMatch.uc.userBasic.name), \(ucMatch.uc.userBasic.birthdate.ageString())")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            //we want to see whether or not a snap or message was sent
                            // a snap trumps a message
                            // priority level:
                            //  1. Unopened snap (does not depend on date)
                            //  2. Unopened message (does not depend  on date)
                            //  3. most recently opened/ sent (either snap or message [does depend on date])
                            //
                            
                            if chatsViewModel.snaps[ucMatch.uc.userBasic.uid] != nil && messages[ucMatch.uc.userBasic.uid] != nil {
                                if chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].openedDate == nil && messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].openedDate == nil{
                                    //There is unopened snaps and messages, we need to render the most recently sent
                                    //the current functionality is good, but a new snap overrides a new message, regardless of time. we only want time if the last message was sent from us
                                    if chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].openedDate == nil && chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].fromID != AuthService.shared.currentUser!.uid{
                                        unopenedSnapToMe
                                    } else if chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].snapID_timestamp > messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].time{
                                        // show unopened snap
                                        //check to see who its from
                                        if chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].fromID == AuthService.shared.currentUser!.uid {
                                            //its from me
                                            unopenedSnapFromMe
                                        } else {
                                            //its to me
                                            unopenedSnapToMe
                                        }
                                    } else {
                                        //show unopened message
                                        //check to see who its from
                                        if messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].fromID == AuthService.shared.currentUser!.uid {
                                            //its from me
                                            unopenedMessageFromMe
                                        } else {
                                            //its to me
                                            unopenedMessageToMe
                                        }
                                    }
                                } else if messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].openedDate == nil && chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].openedDate != nil {
                                    //There is unopened chats but no snaps
                                    if messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].fromID == AuthService.shared.currentUser!.uid {
                                        //its from me
                                        unopenedMessageFromMe
                                    } else {
                                        //its to me
                                        unopenedMessageToMe
                                    }
                                } else if messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].openedDate != nil && chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].openedDate == nil{
                                    //there are unopened snaps but no chats
                                    if chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].fromID == AuthService.shared.currentUser!.uid {
                                        //its from me
                                        unopenedSnapFromMe
                                    } else {
                                        //its to me
                                        unopenedSnapToMe
                                    }
                                } else {
                                    //if they're both opened find which one is newer and display the receipt
                                    if chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].openedDate! > messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].openedDate! {
                                        //show opened snap
                                        //check to see who its from
                                        if chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].fromID == AuthService.shared.currentUser!.uid {
                                            // its from me
                                            openedSnapFromMe
                                        } else {
                                            //its to me
                                            openedSnapToMe
                                        }
                                    } else {
                                        //show opened message
                                        //check to see who its from
                                        if messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].fromID == AuthService.shared.currentUser!.uid {
                                            //its from me
                                            openedMessageFromMe
                                        } else {
                                            //its to me
                                            openedMessageToMe
                                        }
                                    }
                                }
                            } else if chatsViewModel.snaps[ucMatch.uc.userBasic.uid] != nil && messages[ucMatch.uc.userBasic.uid] == nil {
                                //there is snaps but no messages
                                if chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].openedDate == nil {
                                    // show unopened snap
                                    if chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].fromID == AuthService.shared.currentUser!.uid {
                                        unopenedSnapFromMe
                                    } else {
                                        unopenedSnapToMe
                                    }
                                } else {
                                        //show opened snap
                                    if chatsViewModel.snaps[ucMatch.uc.userBasic.uid]![chatsViewModel.snaps[ucMatch.uc.userBasic.uid]!.count - 1].fromID == AuthService.shared.currentUser!.uid {
                                        openedSnapFromMe
                                    } else {
                                        openedSnapToMe
                                    }
                                }
                            } else if chatsViewModel.snaps[ucMatch.uc.userBasic.uid] == nil && messages[ucMatch.uc.userBasic.uid] != nil {
                                // there are messages but no snaps
                                if messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].openedDate == nil {
                                    //show unopened message
                                    if messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].fromID == AuthService.shared.currentUser!.uid {
                                        //its from me
                                        unopenedMessageFromMe
                                    } else {
                                        //its to me
                                        unopenedMessageToMe
                                    }
                                } else {
                                    //show opened message
                                    if messages[ucMatch.uc.userBasic.uid]![messages[ucMatch.uc.userBasic.uid]!.count - 1].fromID == AuthService.shared.currentUser!.uid {
                                        //its from me
                                        openedMessageFromMe
                                    } else {
                                        //its to me
                                        openedMessageToMe
                                    }
                                }
                            } else {
                                //they are both nil
                                newMatch
                            }
                        }
                    }
                    
                    let uid = ucMatch.uc.userBasic.uid
                    
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
            SnapView(show: $showSnapView, snaps: chatsViewModel.getUnopenedSnapsFrom(uid: userChat!.uid), snapViewModel: chatsViewModel)
        })
        .sheet(isPresented: $showProfile, content: {
            ProfileMainView(viewModel: ProfileViewModel(mode: .otherAccount, uid: ucMatch.uc.userBasic.uid), showProfile: $showProfile)
        })
        .frame(width: screenWidth * 0.95, height: screenWidth / 9)
    }
    
    var unopenedSnapFromMe : some View {
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
    
    var unopenedSnapToMe : some View {
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
    
    var openedSnapFromMe: some View {
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
    
    var openedSnapToMe: some View {
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
    
    var unopenedMessageFromMe: some View {
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
    
    var unopenedMessageToMe: some View {
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
    
    var openedMessageFromMe: some View {
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
    
    var openedMessageToMe: some View {
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
    
    var newMatch: some View {
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
