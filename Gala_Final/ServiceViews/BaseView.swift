//
//  BaseView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct BaseView: View {
    var optionButtonLeft: String = "highlighter"
    var pageName: String = "Profile"
    var optionButtonRight: String = "gearshape"
    var baseColor: Color = .blue
    
    var body: some View {
        VStack {
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(baseColor)
                    .offset(y: -10)
                
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.white)
                        .frame(width: screenWidth, height: screenHeight * 0.81)
                        .shadow(radius: 10)
                }
                
//MARK: - Plug view here when using
                VStack {
                    Spacer()
                    ScrollView(showsIndicators: false) {
                        ProfileView(viewModel: ProfileViewModel(name: "Vaughn", age: Date(), mode: .profileStandard))
                    }
                    .frame(width: screenWidth, height: screenHeight * 0.81)
                    .cornerRadius(20)
                }
//MARK: - Plug view here when using
                
                VStack {
                    HStack {
                        Button(action: { }) {
                            Image(systemName: optionButtonLeft)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text(pageName)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)

                        Spacer()
                        
                        Button(action: { }) {
                            Image(systemName: optionButtonRight)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                .padding(.top, screenHeight * 0.0385)
            }
            .frame(width: screenWidth, height: screenHeight * 0.91)
            .edgesIgnoringSafeArea(.all)
            Spacer()
        }
    }
}

struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
//iPhone 12
//        BaseView()
//            .previewDevice("iPhone 12")
//        BaseView()
//            .previewDevice("iPhone 12 Pro")
//        BaseView()
//            .previewDevice("iPhone 12 Pro Max")
//        BaseView()
//            .previewDevice("iPhone 12 Mini")
        
//iPhone 11
        BaseView()
            .previewDevice("iPhone 11")
        BaseView()
            .previewDevice("iPhone 11 Pro")
        BaseView()
            .previewDevice("iPhone 11 Pro Max")

//iPhone 8
        BaseView()
            .previewDevice("iPhone 8")
        BaseView()
            .previewDevice("iPhone 8 Plus")

//iPhone SE/ iPod touch
        BaseView()
            .previewDevice("iPhone SE")
    }
}
