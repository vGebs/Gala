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
    @State var pressed = false
    
    var body: some View {
        HStack{
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .stroke()
                    .frame(width: screenWidth / 9, height: screenWidth / 9)
                    .foregroundColor(.blue)
                    .padding(.trailing)
                
                if viewModel.img == nil {
                    Image(systemName: "person.fill.questionmark")
                        .foregroundColor(Color(.systemTeal))
                        .frame(width: screenWidth / 20, height: screenWidth / 20)
                        .padding(.trailing)
                    
                } else {
                    Image(uiImage: viewModel.img!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth / 9.2, height: screenWidth / 9.2)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.trailing)
                }
            }
            
            VStack{
                Divider()
                Spacer()
                HStack {
                    VStack {
                        HStack {
                            Text("\(viewModel.profile.name), \(viewModel.profile.age.ageString())")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        if matched {
                            HStack {
                                Image(systemName: "arrowtriangle.right")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("Opened")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(.primary)
                                
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
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 8, weight: .semibold, design: .rounded))
                                
                                Text("\(viewModel.city), \(viewModel.country)")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                Spacer()
                            }
                        }
                    }
                    
                    if matched {
                        Image(systemName: "camera")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.buttonPrimary)
                    } else {
                        Button(action: {
                            if self.pressed == false {
                                self.viewModel.likeUser()
                                self.pressed.toggle()
                            } else {
                                self.viewModel.unLikeUser()
                                self.pressed.toggle()
                            }
                        }){
                            Image(systemName: self.pressed ? "checkmark" : "plus.app")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.buttonPrimary)
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
        SmallUserView(viewModel: SmallUserViewModel(profile: UserCore(uid: "123", name: "Vaughn", age: Date(), gender: "Male", sexuality: "Straight", ageMinPref: 18, ageMaxPref: 99, willingToTravel: 22, longitude: 54.22, latitude: 54.22)))
    }
}
