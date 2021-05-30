//
//  SpotlightPreviewView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct SpotlightPreviewView: View {
    var body: some View {
        ZStack {
            ZStack{
                Image("Mountains")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.7)
                
                Color.black.opacity(0.2)
                
                HStack {
                    VStack {
                        ZStack {
                            Image("me")
                                .resizable()
                                .clipShape(Circle())
                                .aspectRatio(contentMode: .fit)
                            
                            Circle().stroke(lineWidth: 3)
                                .foregroundColor(.white)
                                .frame(width: screenWidth / 3.6, height: screenWidth / 3.6, alignment: .center)
                            
                        }
                        .frame(width: screenWidth / 3, height: screenWidth / 3)
                        
                        VStack {
                            Text("Vaughn, 23")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .padding(.bottom, screenWidth / 200)
                            
                            HStack{
                                Image(systemName: "briefcase")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                
                                Text("Engineer")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                            }
                            .padding(.bottom, screenWidth / 200)
                            
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .light, design: .rounded))
                                
                                Text("Regina, SK")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                            }
                            .padding(.bottom, screenWidth / 100)
                        }
                        .offset(y: -screenWidth / 50)
                        
                        Spacer()
                    }
                }
            }
            .frame(width: screenWidth / 2.8, height: screenHeight / 3.7)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Button(action: {  }) {
                ZStack {
                    Circle()
                        .frame(width: screenWidth / 10, height: screenWidth / 10)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                    Image(systemName: "hand.thumbsup")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }
            }
            .offset(y: screenHeight * 0.14)
        }
    }
}

struct SpotlightPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        SpotlightPreviewView()
    }
}
