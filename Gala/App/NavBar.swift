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
    
    var body: some View {
        
        ZStack {
            Color.black
            
            HStack{
                //ProfileView
                ZStack {
                    Color.black
                        .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                    
                    HStack {
                        
                        Image(systemName: "person")
                            .font(.system(size: 21, weight: .light, design: .rounded))
                            .foregroundColor(self.offset >= 0 && self.offset < (screenWidth - screenWidth * 0.5) ? Color(.systemTeal) : .accent)
                        
                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .foregroundColor(Color(.systemTeal))
                            .opacity(self.offset == 0 ? 1 : 0)
                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
                    withAnimation {
                        if self.offset != 0 {
                            simpleSuccess()
                        }
                        self.offset = 0
                    }
                }
                    
                Spacer()
        //MessagesView
                ZStack {
                    Color.black
                        .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                    
                    HStack {
                        Image(systemName: "message")
                            .font(.system(size: 21, weight: .light, design: .rounded))
                            .foregroundColor(self.offset >= screenWidth * 0.5 && self.offset < ((screenWidth * 2) - screenWidth * 0.5) ? Color(.systemTeal) : .accent)
                        
                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .foregroundColor(Color(.systemTeal))
                            .opacity(offset == screenWidth ? 1 : 0)
                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
                    withAnimation{
                        if self.offset != screenWidth {
                            simpleSuccess()
                        }
                        self.offset = screenWidth
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
                            .foregroundColor(self.offset >= ((screenWidth * 2) - screenWidth * 0.5) && self.offset < ((screenWidth * 3) - screenWidth * 0.5) ? Color(.systemTeal) : .accent)
                        
                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .opacity(self.offset == screenWidth * 2 ? 1 : 0)
                            .foregroundColor(Color(.systemTeal))

                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
                    withAnimation{
                        if self.offset != screenWidth * 2 {
                            simpleSuccess()
                        }
                        self.offset = screenWidth * 2
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
                            .foregroundColor(self.offset >= ((screenWidth * 3) - screenWidth * 0.5) && self.offset < ((screenWidth * 4) - screenWidth * 0.5) ? Color(.systemTeal) : .accent)
                        
                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .opacity(self.offset == screenWidth * 3 ? 1 : 0)
                            .foregroundColor(Color(.systemTeal))

                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
                    withAnimation {
                        if self.offset != screenWidth * 3 {
                            simpleSuccess()
                        }
                        self.offset = screenWidth * 3
                    }
                }
                    
                Spacer()
        //SwipeView
                ZStack {
                    Color.black
                        .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                    HStack {
                        Image(systemName: "rectangle.stack.person.crop")
                            .font(.system(size: 21, weight: .light, design: .rounded))
                            .foregroundColor(self.offset >= ((screenWidth * 4) - screenWidth * 0.5) && self.offset < ((screenWidth * 5) - screenWidth * 0.5) ? Color(.systemTeal) : .accent)
                        
                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .opacity(self.offset == screenWidth * 4 ? 1 : 0)
                            .foregroundColor(Color(.systemTeal))

                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
                    withAnimation {
                        if self.offset != screenWidth * 4 {
                            simpleSuccess()
                        }
                        self.offset = screenWidth * 4
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

struct NavBar_Previews: PreviewProvider {
    static var previews: some View {
        
//iPhone 12
        NavBar(offset: .constant(screenWidth * 2))
            .previewDevice("iPhone 12")
        NavBar(offset: .constant(screenWidth * 2))
            .previewDevice("iPhone 12 Pro")
        NavBar(offset: .constant(screenWidth * 2))
            .previewDevice("iPhone 12 Pro Max")
        NavBar(offset: .constant(screenWidth * 2))
            .previewDevice("iPhone 12 Mini")
//iPhone 11
        NavBar(offset: .constant(screenWidth * 2))
            .previewDevice("iPhone 11")
        NavBar(offset: .constant(screenWidth * 2))
            .previewDevice("iPhone 11 Pro")
        NavBar(offset: .constant(screenWidth * 2))
            .previewDevice("iPhone 11 Pro Max")
//iPhone 8
        NavBar(offset: .constant(screenWidth * 2))
            .previewDevice("iPhone 8")
        NavBar(offset: .constant(screenWidth * 2))
            .previewDevice("iPhone 8 Plus")
    }
}
