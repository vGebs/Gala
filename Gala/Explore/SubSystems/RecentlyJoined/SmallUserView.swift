//
//  NewUserView.swift
//  Gala
//
//  Created by Vaughn on 2021-06-11.
//

import SwiftUI
import Combine

protocol SmallUserViewModelProtocol: ObservableObject {
    func likeUser(with id: String)
    func unLikeUser(with id: String)
}

struct SmallUserView<Model>: View where Model: SmallUserViewModelProtocol {
    
    @ObservedObject var viewModel: Model
    @ObservedObject var user: SmallUserViewModel
    
    @State var likePressed = false
    @State var showProfile = false
    var width: CGFloat
    
    var body: some View {
        HStack{
            Button(action: {
                showProfile = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke()
                        .frame(width: screenWidth / 9, height: screenWidth / 9)
                        .foregroundColor(.blue)
                        .padding(.trailing)
                    
                    if user.img == nil {
                        Image(systemName: "person.fill.questionmark")
                            .foregroundColor(Color(.systemTeal))
                            .frame(width: screenWidth / 20, height: screenWidth / 20)
                            .padding(.trailing)
                            
                    } else {
                        Image(uiImage: user.img!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth / 9.2, height: screenWidth / 9.2)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding(.trailing)
                    }
                }
            }
            
            VStack{
                Divider()
                Spacer()
                HStack {
                    Button(action: {
                        showProfile = true
                    }){
                        VStack {
                            HStack {
                                Text("\(user.profile?.userBasic.name ?? ""), \(user.profile?.userBasic.birthdate.ageString() ?? "")")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.buttonPrimary)
                                    .font(.system(size: 8, weight: .semibold, design: .rounded))
                                
                                Text("\(user.city), \(user.country)")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                    }.frame(width: screenWidth * 0.33)
                    
                    Spacer()
                    
                    Button(action: {
                        if self.likePressed == false {
                            self.viewModel.likeUser(with: user.profile!.userBasic.uid)
                            self.likePressed.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
                                self.likePressed.toggle()
                            }
                        }
                    }){
                        Image(systemName: self.likePressed ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.buttonPrimary)
                    }
                }
                
                Spacer()
            }
            Spacer()
        }
        .frame(width: width, height: screenWidth / 9)
        .sheet(isPresented: $showProfile, content: {
            ProfileMainView(viewModel: ProfileViewModel(name: self.user.profile!.userBasic.name, age: user.profile!.userBasic.birthdate, mode: .otherAccount, uid: user.profile!.userBasic.uid), showProfile: $showProfile)
        })
    }
}
