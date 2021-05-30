//
//  ShowcaseView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct ShowcaseView: View {
    var body: some View {
        VStack {
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.green)
                    .offset(y: -10)
                
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.white)
                        .frame(width: screenWidth, height: screenHeight * 0.81)
                        .shadow(radius: 10)
                }
                Text("Coming Soon")
                    .font(.system(size: 35, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                VStack {
                    HStack {
                        Button(action: { }) {
                            ProfilePreview()
//                            Image(systemName: "line.horizontal.3.decrease")
//                                .font(.system(size: 20, weight: .semibold, design: .rounded))
//                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("Showcase")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)

                        Spacer()
                        
                        Button(action: { }) {
                            Image(systemName: "line.horizontal.3.decrease")
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

struct ShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        ShowcaseView()
    }
}
