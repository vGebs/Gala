//
//  NavBar.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI //

struct NavBar: View {
    @Binding var pageSelection: Int
    @Binding var elegantPageSelection: Int
    //@EnvironmentObject var camera: SwiftUICamModel
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
                            .font(.system(size: 21, weight: pageSelection == 0 || elegantPageSelection == 0 ? .light : .light, design: .rounded))
                            .foregroundColor(pageSelection == 0 || elegantPageSelection == 0 ? Color(.systemTeal) : .accent)
                        
                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .foregroundColor(Color(.systemTeal))
                            .opacity(pageSelection == 0 || elegantPageSelection == 0 ? 1 : 0)
                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
                    if pageSelection != 0 {
                        simpleSuccess()
                    }
                    pageSelection = 0
                    elegantPageSelection = 0
                }
                    
                Spacer()
        //MessagesView
                ZStack {
                    Color.black
                        .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                    
                    HStack {
                        Image(systemName: "message")
                            .font(.system(size: 21, weight: pageSelection == 1 || elegantPageSelection == 1 ? .light : .light, design: .rounded))
                            .foregroundColor(pageSelection == 1 || elegantPageSelection == 1 ? Color(.systemTeal) : .accent)
                        
                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .foregroundColor(Color(.systemTeal))
                            .opacity(pageSelection == 1 || elegantPageSelection == 1 ? 1 : 0)
                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
                    
                    if pageSelection != 1 {
                        simpleSuccess()
                    }
                    pageSelection = 1
                    elegantPageSelection = 1
                }

                Spacer()
        //CameraView
                ZStack {
                    Color.black
                        .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                    
                    HStack {
                        Image(systemName: "camera")
                            .font(.system(size: 21, weight: pageSelection == 2 || elegantPageSelection == 2 ? .light : .light, design: .rounded))
                            .foregroundColor(pageSelection == 2 || elegantPageSelection == 2 ? Color(.systemTeal) : .accent)
                        
                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .opacity(pageSelection == 2 || elegantPageSelection == 2 ? 1 : 0)
                            .foregroundColor(Color(.systemTeal))

                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
                    if pageSelection != 2 {
                        simpleSuccess()
                    }
                    pageSelection = 2
                    elegantPageSelection = 2
                }
                    
                Spacer()
        //ExploreView
                ZStack {
                    Color.black
                        .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                    
                    HStack {
                        Image(systemName: "person.2")
                            .font(.system(size: 21, weight: pageSelection == 3 || elegantPageSelection == 3 ? .light : .light, design: .rounded))
                            .foregroundColor(pageSelection == 3 || elegantPageSelection == 3 ? Color(.systemTeal) : .accent)
                        
                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .opacity(pageSelection == 3 || elegantPageSelection == 3 ? 1 : 0)
                            .foregroundColor(Color(.systemTeal))

                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
                    if pageSelection != 3 {
                        simpleSuccess()
                    }
                    pageSelection = 3
                    elegantPageSelection = 3
                }
                    
                Spacer()
        //SwipeView
                ZStack {
                    Color.black
                        .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                    HStack {
                        Image(systemName: "rectangle.stack.person.crop")
                            .font(.system(size: 21, weight: pageSelection == 4 || elegantPageSelection == 4 ? .light : .light, design: .rounded))
                            .foregroundColor(pageSelection == 4 || elegantPageSelection == 4 ? Color(.systemTeal) : .accent)
                        
                        Image(systemName: "poweron")
                            .font(.system(size: 10, weight: .light, design: .rounded))
                            .opacity(pageSelection == 4 || elegantPageSelection == 4 ? 1 : 0)
                            .foregroundColor(Color(.systemTeal))

                    }
                }
                .frame(width: screenWidth / 5.5, height: screenWidth / 8)
                .onTapGesture {
                    if pageSelection != 4 {
                        simpleSuccess()
                    }
                    pageSelection = 4
                    elegantPageSelection = 4
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
        NavBar(pageSelection: .constant(2), elegantPageSelection: .constant(2))
            .previewDevice("iPhone 12")
        NavBar(pageSelection: .constant(2), elegantPageSelection: .constant(2))
            .previewDevice("iPhone 12 Pro")
        NavBar(pageSelection: .constant(2), elegantPageSelection: .constant(2))
            .previewDevice("iPhone 12 Pro Max")
        NavBar(pageSelection: .constant(2), elegantPageSelection: .constant(2))
            .previewDevice("iPhone 12 Mini")
//iPhone 11
        NavBar(pageSelection: .constant(2), elegantPageSelection: .constant(2))
            .previewDevice("iPhone 11")
        NavBar(pageSelection: .constant(2), elegantPageSelection: .constant(2))
            .previewDevice("iPhone 11 Pro")
        NavBar(pageSelection: .constant(2), elegantPageSelection: .constant(2))
            .previewDevice("iPhone 11 Pro Max")
//iPhone 8
        NavBar(pageSelection: .constant(2), elegantPageSelection: .constant(2))
            .previewDevice("iPhone 8")
        NavBar(pageSelection: .constant(2), elegantPageSelection: .constant(2))
            .previewDevice("iPhone 8 Plus")
    }
}
