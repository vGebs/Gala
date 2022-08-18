//
//  NavBar.swift
//  Gala
//
//  Created by Vaughn on 2022-08-18.
//

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
    }
}

