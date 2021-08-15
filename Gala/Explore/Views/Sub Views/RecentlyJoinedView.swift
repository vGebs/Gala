//
//  RecentlyJoinedView.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import SwiftUI

struct RecentlyJoinedView: View {
    
    @Binding var newUsers: [UserCore]
    @State var showAll = false
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    HStack {
                        Text("Newcomers")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                        
                        Spacer()
                        
                        Button(action: {
                            self.showAll = true
                        }) {
                            Text("See All")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        .frame(height: screenWidth * 0.1)
                    }
                    .frame(width: screenWidth * 0.9)
                    .padding(.leading)
                    .padding(.trailing)
                    
                    HStack {
                        TabView {
                            ForEach(0..<((newUsers.count + 1) / 2), id: \.self) { i in
                                VStack {
                                    if i * 2 < newUsers.count{
                                        SmallUserView(viewModel: SmallUserViewModel(profile: newUsers[i * 2]), matched: false)
                                            .padding(.bottom, 3)
                                    }
                                    
                                    if i * 2 + 1 < newUsers.count{
                                        SmallUserView(viewModel: SmallUserViewModel(profile: newUsers[i * 2 + 1]), matched: false)
                                        
                                    }
                                    
                                    if i * 2 + 1 == newUsers.count {
                                        Spacer()
                                            .frame(height: 50)
                                    }
                                }
                            }
                        }
                        .offset(y: -screenHeight * 0.017)
                        .frame(width: screenWidth, height: screenHeight / 7.5)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                    .frame(width: screenWidth, height: screenHeight / 7.5)
                    
                    Spacer()
                }
            }
        }
//        .sheet(isPresented: $showAll, content: {
//            AllRecentsView(allNewUsers: $newUsers)
//        })
        .preferredColorScheme(.dark)
    }
}

struct RecentlyJoinedView_Previews: PreviewProvider {
    static var previews: some View {
        RecentlyJoinedView(newUsers: .constant(arr2))
            .preferredColorScheme(.dark)
    }
}

var arr2: [UserCore] = [
//    ProfileModel(name: "Vaughn", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "joe", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "sam", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "ye", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "yee", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "yeye", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "bb", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "aa", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "qq", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "rr", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "tt", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "yy", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "uu", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "ii", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R")
]

struct MyDivider: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .frame(width: screenWidth * 0.9, height: screenHeight / 800)
            .foregroundColor(.accent)
            .padding(.top, 5)
            .offset(y: -screenHeight * 0.017)
    }
}

//struct RecentlyJoinedView: View {
//
//    @Binding var newUsers: [ProfileModel]
//    @State var showAll = false
//
//    var body: some View {
//        ZStack {
//            ScrollView(.vertical, showsIndicators: false) {
//                VStack {
//                    HStack {
//                        Text("Recently Joined")
//                            .font(.system(size: 25, weight: .bold, design: .rounded))
//
//                        Spacer()
//
//                        Button(action: {
//                            self.showAll = true
//                        }) {
//                            Text("See All")
//                                .font(.system(size: 16, weight: .medium, design: .rounded))
//                        }
//                        .frame(height: screenWidth * 0.1)
//                    }
//                    .frame(width: screenWidth * 0.85)
//                    .padding(.leading)
//                    .padding(.trailing)
//                    .padding(.top)
//
//                    HStack {
//                        TabView {
//                            ForEach(0..<(newUsers.count / 2)){ i in
//                                ForEach(0..<1){ j in
//                                    VStack{
//                                        if i == 0 {
//                                            SmallUserView(
//                                                viewModel: RecentlyJoinedViewModel(
//                                                    profile: newUsers[j])
//                                            )
//                                            .padding(.bottom, 3)
//
//                                            SmallUserView(
//                                                viewModel: RecentlyJoinedViewModel(
//                                                    profile: newUsers[j + 1])
//                                            )
//                                        } else {
//                                            SmallUserView(
//                                                viewModel: RecentlyJoinedViewModel(
//                                                    profile: newUsers[j + (i * 2)])
//                                            )
//                                            .padding(.bottom, 3)
//
//                                            SmallUserView(
//                                                viewModel: RecentlyJoinedViewModel(
//                                                    profile: newUsers[j + (i * 2) + 1])
//                                            )
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        .frame(width: screenWidth, height: screenHeight / 4.5)
//                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//                    }
//                    .frame(width: screenWidth, height: screenHeight / 7.5)
//
//                    RoundedRectangle(cornerRadius: 5)
//                        .frame(width: screenWidth * 0.85, height: screenHeight / 800)
//                        .foregroundColor(.gray)
//                        .padding(.top)
//
//                    Spacer()
//                }
//            }
//        }
//        .sheet(isPresented: $showAll, content: {
//            AllRecentsView(allNewUsers: $newUsers)
//        })
//        .preferredColorScheme(.dark)
//    }
//}
//
//struct RecentlyJoinedView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecentlyJoinedView(newUsers: .constant(arr2))
//            .preferredColorScheme(.dark)
//    }
//}
//
//var arr2: [ProfileModel] = [
//    ProfileModel(name: "Vaughn", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "joe", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "sam", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "ye", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "yee", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "yeye", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "bb", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "aa", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "qq", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "rr", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "tt", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "yy", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "uu", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
//    ProfileModel(name: "ii", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R")
//]
