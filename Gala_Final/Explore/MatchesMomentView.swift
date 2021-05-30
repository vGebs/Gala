//
//  MatchesMomentView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct MatchesMomentView: View {
    @Binding var viewed: Bool
    
    var body: some View {
        VStack{
            ZStack {
                Image("me")
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fill)
                    .frame(width: screenWidth / 5.2, height: screenWidth / 5.2)
                if viewed {
                    ZStack {
                        Circle()
                            .frame(width: screenWidth / 5.2, height: screenWidth / 5.2)
                            .opacity(0.5)
                        
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.white)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                    }
                }

                Circle().stroke(lineWidth: 3)
                    .foregroundColor(.blue)
                    .opacity(viewed ? 0.4 : 1)
                    .frame(width: screenWidth / 4.8, height: screenWidth / 4.8)
            }
            
            Text("Vaughn")
                .foregroundColor(.black)
                .font(.system(size: 13, weight: .medium, design: .rounded))
        }
    }
}

struct MatchesMomentView_Previews: PreviewProvider {
    static var previews: some View {
        MatchesMomentView(viewed: .constant(false))
    }
}
