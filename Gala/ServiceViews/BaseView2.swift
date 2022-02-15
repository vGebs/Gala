//
//  BaseView2.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

//struct BaseView2: View {
//    var optionButtonLeft: String = "highlighter"
//    var pageName: String = "Profile"
//    var optionButtonRight: String = "gearshape"
//    var baseColor: Color = .blue
//    
//    var body: some View {
//        VStack {
//            ZStack{
//                
//                RoundedRectangle(cornerRadius: 20)
//                    .foregroundColor(.white)
//                    .offset(y: -10)
//
//                VStack {
//                    HStack {
//                        Button(action: { }) {
//                            Image(systemName: optionButtonLeft)
//                                .font(.system(size: 20, weight: .semibold, design: .rounded))
//                                //.foregroundColor(.white)
//                        }
//                        
//                        Spacer()
//                        
//                        Text(pageName)
//                            .font(.system(size: 20, weight: .semibold, design: .rounded))
//                            //.foregroundColor(.white)
//
//                        Spacer()
//                        
//                        Button(action: { }) {
//                            Image(systemName: optionButtonRight)
//                                .font(.system(size: 20, weight: .semibold, design: .rounded))
//                                //.foregroundColor(.white)
//                        }
//                    }
//                    .padding()
//                    
//                    ScrollView{
//                        ProfileView(viewModel: ProfileViewModel(name: "Vaughn", age: Date(), mode: .profileStandard))
//                    }
//                    .cornerRadius(20)
//                    
//                    Spacer()
//                }
//                .padding(.top, screenHeight * 0.0385)
//            }
//            .frame(width: screenWidth, height: screenHeight * 0.91)
//            .edgesIgnoringSafeArea(.all)
//            Spacer()
//        }
//    }
//}
