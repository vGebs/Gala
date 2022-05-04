//
//  NavBar.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct NavBarNN: View {
    
    @Binding var offset: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack {
            Color.black
            
            HStack{
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
                        
                        self.offset = screenWidth * 2
                    }
                }
                Spacer()
            }
        }
        .frame(width: screenWidth, height: screenWidth / 8)
    }
    
    func simpleSuccess(){
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
