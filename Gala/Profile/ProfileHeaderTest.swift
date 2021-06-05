//
//  ProfileHeaderTest.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct ProfileHeaderTest: View {
    var body: some View {
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
                            .frame(width: screenWidth / 3, height: screenWidth / 3, alignment: .center)
                        
                    }
                    .frame(width: screenWidth / 2.4, height: screenWidth / 2.4)
                    
                    VStack {
                        Text("Vaughn, 23")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .padding(.bottom, screenWidth / 200)
                        
                        HStack{
                            Image(systemName: "briefcase")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                            
                            Text("Engineer")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        .padding(.bottom, screenWidth / 200)
                        
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .light, design: .rounded))
                            
                            Text("Regina, SK")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                        }
                        .padding(.bottom, screenWidth / 100)
                    }
                    .offset(y: -screenWidth / 50)
                    
                    Spacer()
                }
                .padding(.leading, 35)
                
                //Spacer()
                
                VStack{
                    HStack {
                        Text("Bio")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .padding(.top, 20)
                        Spacer()
                    }
                    
                    Text("Sporty kinda guy. Play with me. Im really fun and i like to play other board games")
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                    
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack {
                            Image("me")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding(.trailing, 5)
                                .padding(.leading, 5)
                            
                            Image("me")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding(.trailing, 5)
                            
                            Image("me")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding(.trailing, 5)
                            
                            Image("me")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding(.trailing, 5)
                            
                            Image("me")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding(.trailing, 5)

                            Image("me")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding(.trailing, 5)
                        }
                    }
                    .padding(.bottom, 12)
                }
                .padding(.trailing, 35)
            }
        }
        .frame(width: screenWidth, height: screenHeight / 3)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct ProfileHeaderTest_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHeaderTest()
    }
}
