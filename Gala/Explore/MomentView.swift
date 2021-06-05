//
//  MomentView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct Moment: Identifiable{
    var id = UUID()
    var imageString: String
    var name: String
    var age: String
    var title: String
}

struct MomentView: View {
    var imageString = "me"
    var name = "Vaughn"
    var age = "23"
    var title = "Engineer"
    @State var liked = false
    
    var body: some View {
        ZStack{
            Color.white
                .frame(width: screenWidth / 2.2, height: screenHeight / 3)
                .cornerRadius(30)
                .shadow(color: .dropShadow, radius: 15, x: 10, y: 10)
                .shadow(color: .dropLight, radius: 15, x: -10, y: -10)
                
            VStack{
                ZStack {
                    Image(imageString)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .aspectRatio(contentMode: .fit)
                        
                    VStack{
                        Spacer()
                        HStack{
//                                Image(systemName: "heart.text.square")
//                                    .font(.system(size: 22, weight: .bold, design: .rounded))
//                                    .foregroundColor(.white)
//                                    .shadow(radius: 20)

                            Spacer()
                            Button(action: { self.liked.toggle() }) {
                                Image(systemName: liked ? "heart" : "heart.circle")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(radius: 20)
                            }
                            
                        }
                        //.padding(.leading, screenWidth * 0.02)
                        .padding(.trailing, screenWidth * 0.055)
                        .padding(.bottom, screenWidth * 0.02)
                    }
                        
                }
                .frame(width: screenWidth / 2.3, height: screenHeight / 3.9)
                .padding(.top, screenHeight * 0.007)

                    
                Spacer()
                    
                HStack {
                    Text("\(name), \(age)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.black)

                    Spacer()
                }
                .padding(.leading, 15)
                    
                HStack {
                    Text(title)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.leading, 15)
                .padding(.bottom, 20)

            }
            .frame(width: screenWidth / 2.5, height: screenHeight / 3)
        }
        .frame(width: screenWidth / 2.2, height: screenHeight / 3)
    }
}

struct MomentView_Previews: PreviewProvider {
    static var previews: some View {
        MomentView().previewDevice("iPhone 11")
        MomentView().previewDevice("iPhone 11 Pro")
        MomentView().previewDevice("iPhone 11 Pro Max")
        
        MomentView().previewDevice("iPhone 12")
        MomentView().previewDevice("iPhone 12 Pro")
        MomentView().previewDevice("iPhone 12 Pro Max")
        MomentView().previewDevice("iPhone 12 Mini")
        
        MomentView().previewDevice("iPhone 8")
        MomentView().previewDevice("iPhone 8 Plus")



    }
}
