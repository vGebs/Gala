//
//  NewNavBar.swift
//  Gala
//
//  Created by Vaughn on 2022-05-04.
//

import Foundation
import SwiftUI
import Combine

struct NavBar: View {
    @Binding var offset: CGFloat
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.black)
                    .opacity(0.85)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke()
                    .foregroundColor(.accent)
                
                HStack {
                    
                    Image(systemName: "message")
                        .font(.system(
                            size: 21,
                            weight: self.offset >= 0 && self.offset < (screenWidth - screenWidth * 0.5) ? .bold : .light,
                            design: .rounded
                        ))
                        .foregroundColor(self.offset >= 0 && self.offset < (screenWidth - screenWidth * 0.5) ? .primary : .white)
                        .padding(.leading)
                        .onTapGesture {
                            withAnimation{
                                self.offset = 0
                            }
                        }
                    
                    Image(systemName: "poweron")
                        .font(.system(
                            size: 11,
                            weight: .light,
                            design: .rounded
                        ))
                        .foregroundColor(.white)
                        .opacity(offset == 0 ? 1 : 0)
                    
                    Spacer()
                    
                    Image(systemName: "poweron")
                        .font(.system(
                            size: 11,
                            weight: .light,
                            design: .rounded
                        ))
                        .foregroundColor(.white)
                        .opacity(offset == screenWidth ? 1 : 0)
                    
                    Image(systemName: "camera")
                        .font(.system(
                                size: 21,
                                weight: self.offset >= screenWidth * 0.5 && self.offset < ((screenWidth * 2) - screenWidth * 0.5) ? .bold : .light,
                                design: .rounded
                        ))
                        .foregroundColor(self.offset >= screenWidth * 0.5 && self.offset < ((screenWidth * 2) - screenWidth * 0.5) ? .primary : .white)
                        .onTapGesture {
                            withAnimation{
                                self.offset = screenWidth
                            }
                        }
                    
                    Image(systemName: "poweron")
                        .font(.system(
                            size: 11,
                            weight: .light,
                            design: .rounded
                        ))
                        .foregroundColor(.white)
                        .opacity(offset == screenWidth ? 1 : 0)
                    
                    Spacer()
                    
                    Image(systemName: "poweron")
                        .font(.system(
                            size: 11,
                            weight: .light,
                            design: .rounded
                        ))
                        .foregroundColor(.white)
                        .opacity(offset == screenWidth * 2 ? 1 : 0)
                    
                    Image(systemName: "person.2")
                        .font(.system(
                            size: 21,
                            weight: self.offset >= ((screenWidth * 2) - screenWidth * 0.5) && self.offset < ((screenWidth * 3) - screenWidth * 0.5) ? .bold : .light,
                            design: .rounded
                        ))
                        .foregroundColor(self.offset >= ((screenWidth * 2) - screenWidth * 0.5) && self.offset < ((screenWidth * 3) - screenWidth * 0.5) ? .primary : .white)
                        .padding(.trailing)
                        .onTapGesture {
                            withAnimation {
                                self.offset = screenWidth * 2
                            }
                        }
                }
            }
            .frame(width: screenWidth * 0.6, height: screenWidth / 8)
        }
        
//        HStack {
//            ZStack {
//                Image(systemName: "message")
//                    .font(.system(
//                        size: 21,
//                        weight: self.offset >= 0 && self.offset < (screenWidth - screenWidth * 0.5) ? .bold : .light,
//                        design: .rounded
//                    ))
//                    .opacity(0)
//
//                Image(systemName: "chevron.up")
//                    .font(.system(
//                        size: 16,
//                        weight: .light,
//                        design: .rounded
//                    ))
//                    .opacity(self.offset == 0 ? 1 : 0)
//            }
//            .padding(.leading)
//
//            Spacer()
//
//            ZStack {
//                Image(systemName: "camera")
//                    .font(.system(
//                            size: 21,
//                            weight: self.offset >= screenWidth * 0.5 && self.offset < ((screenWidth * 2) - screenWidth * 0.5) ? .bold : .light,
//                            design: .rounded
//                    ))
//                    .opacity(0)
//
//                Image(systemName: "chevron.up")
//                    .font(.system(
//                        size: 16,
//                        weight: .light,
//                        design: .rounded
//                    ))
//                    .opacity(offset == screenWidth ? 1 : 0)
//            }
//
//            Spacer()
//
//            ZStack {
//                Image(systemName: "person.2")
//                    .font(.system(
//                        size: 21,
//                        weight: self.offset >= ((screenWidth * 2) - screenWidth * 0.5) && self.offset < ((screenWidth * 3) - screenWidth * 0.5) ? .bold : .light,
//                        design: .rounded
//                    ))
//                    .opacity(0)
//
//                Image(systemName: "chevron.up")
//                    .font(.system(
//                        size: 16,
//                        weight: .light,
//                        design: .rounded
//                    ))
//                    .opacity(self.offset == screenWidth * 2 ? 1 : 0)
//            }
//            .padding(.trailing)
//        }
//        .offset(y: screenHeight * 0.04)
//        .frame(width: screenWidth * 0.6, height: screenWidth / 8)
    }
}
