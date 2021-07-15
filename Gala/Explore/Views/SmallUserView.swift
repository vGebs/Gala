//
//  NewUserView.swift
//  Gala
//
//  Created by Vaughn on 2021-06-11.
//

import SwiftUI

struct SmallUserView: View {
    
    @StateObject var viewModel: SmallUserViewModel
    var matched = false
    
    var body: some View {
        HStack{
            RoundedRectangle(cornerRadius: 5)
                .stroke()
                .frame(width: screenWidth / 9, height: screenWidth / 9)
                .foregroundColor(.blue)
                .padding(.trailing)
            
            VStack{
                Divider()
                Spacer()
                HStack {
                    VStack {
                        HStack {
                            Text("\(viewModel.profile.name), \(viewModel.profile.age.ageString())")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(.pink)
                            Spacer()
                        }
                        
                        if matched {
                            HStack {
                                Image(systemName: "arrowtriangle.right")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.pink)
                                
                                Text("Opened")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(.pink)
                                
                                Image(systemName: "circlebadge.fill")
                                    //.resizable()
                                    .font(.system(size: 5, weight: .regular, design: .rounded))
                                    //.frame(width: 3, height: 3)
                                
                                Text("2h")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                Spacer()
                            }
                        } else {
                            HStack {
                                Text("\(viewModel.city), \(viewModel.country)")

                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                Spacer()
                            }
                        }
                    }
                    
                    
                    Button(action: {
                        
                    }){
                        if matched {
                            Image(systemName: "camera")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                        } else {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                        }
                    }
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(width: screenWidth * 0.9, height: screenWidth / 9)
    }
}

struct SmallUserView_Previews: PreviewProvider {
    static var previews: some View {
        SmallUserView(viewModel: SmallUserViewModel(profile: UserSimpleModel(uid: "123", name: "Vaughn", age: Date(), gender: "Male", sexuality: "Straight", longitude: 54.22, latitude: 54.22)))
    }
}

//struct SmallUserView: View {
//
//    @StateObject var viewModel: RecentlyJoinedViewModel
//
//    var body: some View {
//        HStack{
//            RoundedRectangle(cornerRadius: 5)
//                .stroke()
//                .frame(width: screenWidth / 9, height: screenWidth / 9)
//                .foregroundColor(.blue)
//                .padding(.trailing)
//
//            VStack{
//                Divider()
//                Spacer()
//                HStack {
//                    Text("\(viewModel.profile.name), \(viewModel.profile.birthday.ageString())")
//                        .font(.system(size: 17, weight: .medium, design: .rounded))
//                        .foregroundColor(.pink)
//                    Spacer()
//                }
//
//                HStack {
//                    Text("\(viewModel.profile.city), \(viewModel.profile.country)")
//                        .font(.system(size: 13, weight: .regular, design: .rounded))
//                    Spacer()
//                }
//                Spacer()
//            }
//            Spacer()
//
//            Button(action: {
//
//            }){
//                Image(systemName: "ellipsis")
//                    .font(.system(size: 18, weight: .medium, design: .rounded))
//            }
//        }
//        .frame(width: screenWidth * 0.85, height: screenWidth / 9)
//    }
//}
//
//struct NewUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        SmallUserView(viewModel: RecentlyJoinedViewModel(profile: ProfileModel(name: "Vaughn", birthday: Date(), city: "Regina", country: "Canada", userID: "123", bio: "Sup", gender: "Male", sexuality: "Straight", job: "Engg", school: "uofr")))
//    }
//}
