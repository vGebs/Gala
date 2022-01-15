//
//  NavBar.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct NavBar: View {
    
    @Binding var offset: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var storiesPressed: Bool
    @Binding var vibesPressed: Bool
    
    var body: some View {
        
        ZStack {
            Color.black
            
            HStack{
                //ProfileView
                ZStack {
                    Color.black
                        .frame(width: screenWidth / 5.5, height: screenWidth / 8)

                    HStack {

                        Image(systemName: "newspaper")
                            .font(.system(size: 21, weight: .light, design: .rounded))
                            .foregroundColor(storiesPressed ? .primary : .accent) //self.offset >= 0 && self.offset < (screenWidth - screenWidth * 0.5) ? Color(.systemTeal) : .accent

                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .foregroundColor(.primary)
                            .opacity(storiesPressed ? 1 : 0)
                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
//                    withAnimation {
//                        if self.offset != 0 {
//                            simpleSuccess()
//                        }
//                        self.offset = 0
//                    }
                    if vibesPressed {
                        vibesPressed.toggle()
                        storiesPressed.toggle()
                    } else {
                        storiesPressed.toggle()
                    }
                }
//                HStack{
//                    Spacer()
//                    Spacer()
//                    Spacer()
//                }
                
                Spacer()
                
        //MessagesView
                ZStack {
                    Color.black
                        .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                    
                    HStack {
                        Image(systemName: "message")
                            .font(.system(size: 21, weight: .light, design: .rounded))
                            .foregroundColor(self.offset >= 0 && self.offset < (screenWidth - screenWidth * 0.5) ? Color(.systemTeal) : .accent)
                            //.foregroundColor(self.offset >= screenWidth * 0.5 && self.offset < ((screenWidth * 2) - screenWidth * 0.5) ? Color(.systemTeal) : .accent)
                        
                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .foregroundColor(Color(.systemTeal))
                            .opacity(self.offset == 0 ? 1 : 0)
                        //.opacity(offset == screenWidth ? 1 : 0)
                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
                    withAnimation{
                        if self.offset != 0 {
                            simpleSuccess()
                        }
                        
                        if vibesPressed {
                            vibesPressed.toggle()
                        }
                        
                        if storiesPressed {
                            storiesPressed.toggle()
                        }
                        
                        self.offset = 0
                    }
                }

                Spacer()
        //CameraView
                ZStack {
                    Color.black
                        .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                    
                    HStack {
                        Image(systemName: "camera")
                            .font(.system(size: 21, weight: .light, design: .rounded))
                            .foregroundColor(self.offset >= screenWidth * 0.5 && self.offset < ((screenWidth * 2) - screenWidth * 0.5) ? Color(.systemTeal) : .accent)
                            //.foregroundColor(self.offset >= ((screenWidth * 2) - screenWidth * 0.5) && self.offset < ((screenWidth * 3) - screenWidth * 0.5) ? Color(.systemTeal) : .accent)
                        
                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .opacity(offset == screenWidth ? 1 : 0)
                        //.opacity(self.offset == screenWidth * 2 ? 1 : 0)
                            .foregroundColor(Color(.systemTeal))

                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
                    withAnimation{
                        if self.offset != screenWidth {
                            simpleSuccess()
                        }
                        
                        if vibesPressed {
                            vibesPressed.toggle()
                        }
                        
                        if storiesPressed {
                            storiesPressed.toggle()
                        }
                        
                        self.offset = screenWidth
                    }
                }
                    
                Spacer()
        //ExploreView
                ZStack {
                    Color.black
                        .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                    
                    HStack {
                        Image(systemName: "person.2")
                            .font(.system(size: 21, weight: .light, design: .rounded))
                            .foregroundColor(self.offset >= ((screenWidth * 2) - screenWidth * 0.5) && self.offset < ((screenWidth * 3) - screenWidth * 0.5) ? Color(.systemTeal) : .accent)
                        
                        //.foregroundColor(self.offset >= ((screenWidth * 3) - screenWidth * 0.5) && self.offset < ((screenWidth * 4) - screenWidth * 0.5) ? Color(.systemTeal) : .accent)
                        
                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .opacity(self.offset == screenWidth * 2 ? 1 : 0)
                        //.opacity(self.offset == screenWidth * 3 ? 1 : 0)
                            .foregroundColor(Color(.systemTeal))

                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
                    withAnimation {
                        if self.offset != screenWidth * 2 {
                            simpleSuccess()
                        }
                        
                        if vibesPressed {
                            vibesPressed.toggle()
                        }
                        
                        if storiesPressed {
                            storiesPressed.toggle()
                        }
                        
                        self.offset = screenWidth * 2
                    }
                }
                
//                HStack {
//                    Spacer()
//                    Spacer()
//                    Spacer()
//                }
                
                Spacer()
                
        //SwipeView
                ZStack {
                    Color.black
                        .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                    HStack {
                        Image(systemName: "dot.radiowaves.up.forward")
                            .rotationEffect(.degrees(-90))
                            .font(.system(size: 24, weight: .light, design: .rounded))
                            .foregroundColor(vibesPressed ? .primary : .accent) //self.offset >= ((screenWidth * 4) - screenWidth * 0.5) && self.offset < ((screenWidth * 5) - screenWidth * 0.5) ? Color(.systemTeal) : .accent

                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .opacity(vibesPressed ? 1 : 0)
                            .foregroundColor(.primary)

                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
//                    withAnimation {
//                        if self.offset != screenWidth * 4 {
//                            simpleSuccess()
//                        }
//                        self.offset = screenWidth * 4
//                    }
                    if storiesPressed {
                        storiesPressed.toggle()
                        vibesPressed.toggle()
                    } else {
                        vibesPressed.toggle()
                    }
                }
            }
        }
        .frame(width: screenWidth, height: screenWidth / 8)
    }
    
    func simpleSuccess(){
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
