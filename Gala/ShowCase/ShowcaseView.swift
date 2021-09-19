//
//  ShowcaseView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct ShowcaseView: View {
    var optionButtonLeft: String = "rectangle.stack.person.crop"
    var pageName: String = "Showcase"
    var optionButtonRight: String = "square.stack"
    
    //@ObservedObject var viewModel: ProfileViewModel

    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        VStack {
            ZStack{
                Color.black.edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(isDarkMode ? .black : .white)
                        .frame(width: screenWidth, height: screenHeight * 0.81)
                        .shadow(radius: 10)
                }
                VStack{
                    Spacer()
                    VStack {
                        SwipeView()
                    }
                    .frame(width: screenWidth, height: screenHeight * 0.81)
                    .cornerRadius(20)
                }
                
                
                VStack {
                    HStack {
                        Button(action: { }) {
                            Image(systemName: optionButtonLeft)
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                                .foregroundColor(.buttonPrimary)
                        }
                        
                        Spacer()
                        
                        Text(pageName)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)

                        Spacer()
                        
                        Menu {
                            Button(action: { //AppState.shared.toggleDarkMode()
                            }){
                                HStack{
                                    Image(systemName: "calendar")
                                    Text("Sort by age")
                                }
                            }
                            
                            Button(action: {
                                
                            }){
                                HStack{
                                    Image(systemName: "mappin.and.ellipse")
                                    Text("Sort by distance")
                                }
                            }
                            
                            Button(action: {
                                
                            }){
                                HStack{
                                    Image(systemName: "clock")
                                    Text("Sort by most recent")
                                }
                            }
                            
                            Button(action: {
                                
                            }){
                                HStack{
                                    Image(systemName: "shuffle")
                                    Text("Shuffle")
                                }
                            }
                        } label: {
                            Label("", systemImage: optionButtonRight)
                                .foregroundColor(.buttonPrimary)
                                .font(.system(size: 20, weight: .regular, design: .rounded))

                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
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
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct ShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        ShowcaseView()
    }
}
