//
//  StoryView.swift
//  Gala
//
//  Created by Vaughn on 2021-09-12.
//

import SwiftUI

struct StoryView: View {
    //@Binding var story: Story
    var body: some View {
        VStack{
            ZStack{
                
                Image("me")
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth / 2.45, height: screenWidth / 2.45)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    //.padding(.trailing)
                
                RoundedRectangle(cornerRadius: 5)
                    .stroke()
                    .foregroundColor(.buttonPrimary)
                    .frame(width: screenWidth / 2.45, height: screenWidth / 2.45)
            }
            
            Text("Vaughn, 24") //story.meta.userCore.name
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(width: screenWidth / 2.45)
        .padding(.leading, 1)
        .padding(.trailing, 1)
    }
}

//struct StoryView_Previews: PreviewProvider {
//    let meta = StoryMeta(
//        postID_timeAndDatePosted: "\(Date())",
//        userCore: UserCore(
//            uid: "123",
//            name: "Vaughn",
//            age: Date(),
//            gender: "male",
//            sexuality: "Straight",
//            ageMinPref: 18,
//            ageMaxPref: 33,
//            willingToTravel: 30,
//            longitude: 50,
//            latitude: 50
//        )
//    )
//    static var previews: some View {
//        StoryView(story: .constant(Story(meta: <#T##StoryMeta#>, image: <#T##UIImage#>)))
//    }
//}
