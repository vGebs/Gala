//
//  ChatsView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct ChatsView: View {
    @State private var chatsToggle = true

    var body: some View {
        VStack {
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color(#colorLiteral(red: 1, green: 0.6, blue: 0.6, alpha: 1)))
                    .offset(y: -10)
                
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.white)
                        .frame(width: screenWidth, height: screenHeight * 0.81)
                        .shadow(radius: 10)
                }
                
                VStack{
                    Spacer()
                    ScrollView(showsIndicators: false){
                        ForEach(arr.indices) { i in
                            if i == 0 {
                                arr[i]
                                    .padding(.top, 5)
                            } else if i == arr.count - 1 {
                                arr[i]
                                    .padding(.bottom, 10)
                            } else {
                                arr[i]
                            }
                        }
                    }
                    .frame(width: screenWidth, height: screenHeight * 0.81)
                    .cornerRadius(20)
                }
                
                VStack {
                    HStack{
                        Button(action: { }) {
                            ProfilePreview()
//                            Image(systemName: "magnifyingglass")
//                                .font(.system(size: 20, weight: .semibold, design: .rounded))
//                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text("Chats")
                            .font(.system(size: chatsToggle ? 20 : 12, weight: chatsToggle ? .semibold : .medium, design: .rounded))
                            .foregroundColor(chatsToggle ? .white: .white)
                            .onTapGesture {
                                chatsToggle = true
                            }
                        Image(systemName: "decrease.quotelevel")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(chatsToggle ? 1 : 0)
                        Spacer()
                        Text("New Matches")
                            .font(.system(size: !chatsToggle ? 20 : 12, weight: !chatsToggle ? .semibold : .medium, design: .rounded))
                            .foregroundColor(.white)
                            .onTapGesture {
                                chatsToggle = false
                            }
                        Image(systemName: "decrease.quotelevel")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(!chatsToggle ? 1 : 0)
                        Spacer()
                        Button(action: { }) {
                            Image(systemName: "magnifyingglass")
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

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
    }
}

var arr = [
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView(),
    ConvoPreviewView()
]
