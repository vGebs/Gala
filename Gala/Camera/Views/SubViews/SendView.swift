//
//  SendVieww.swift
//  Gala
//
//  Created by Vaughn on 2021-09-22.
//

import SwiftUI

struct SendView: View {
    @Binding var isPresented: Bool
    @ObservedObject var camera: CameraViewModel
    @ObservedObject var viewModel: SendViewModel
    @ObservedObject var chatsViewModel: ChatsViewModel = AppState.shared.chatsVM!
    
    //@State var selected: String = ""
    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                RoundedRectangle(cornerRadius: 2)
                    .foregroundColor(.accent)
                    .frame(width: screenWidth / 4, height: screenHeight / 400)
                    .padding()
                
                ScrollView(showsIndicators: false) {
                    addToVibeView
                    sendToMatchesView
                }
                .frame(width: screenWidth)
            }
            .frame(width: screenWidth)
            
            VStack{
                Spacer()
                Button(action: {
                    self.viewModel.postStory(pic: camera.image!)
                    self.camera.deleteAsset()
                    self.viewModel.selected = ""
                    self.isPresented = false
                }){
                    postButton
                }
                .disabled(viewModel.selected == "")
                .opacity(viewModel.selected != "" ? 1 : 0.4)
            }
        }
    }
    
    var addToVibeView: some View {
        VStack{
            HStack{
                Text("Add your story to a vibe")
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Spacer()
                
                Menu {
                    Text("Posts in vibes will be seen by your matches")
                } label: {
                    Label("", systemImage: "exclamationmark.circle")
                        .foregroundColor(.buttonPrimary)
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .padding(.top, 3)
            .frame(width: screenWidth * 0.9)
            
            ForEach(0..<viewModel.vibes.count, id: \.self){ i in
                PostSelector(selected: viewModel.selected, text: viewModel.vibes[i])
                    .frame(width: screenWidth * 0.9)
                    .onTapGesture {
                        if viewModel.selected == viewModel.vibes[i] {
                            viewModel.selected = ""
                        } else {
                            viewModel.selected = viewModel.vibes[i]
                        }
                    }
            }
            
            PostSelector(selected: viewModel.selected, text: "Add a private story")
                .frame(width: screenWidth * 0.9)
                .onTapGesture {
                    if viewModel.selected == "Add a private story" {
                        viewModel.selected = ""
                    } else {
                        viewModel.selected = "Add a private story"
                    }
                }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 5)
    }
    
    var sendToMatchesView: some View {
        VStack {
            HStack{
                Text("Send to your matches")
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Spacer()
                
                ForEach(chatsViewModel.matches) { match in
                    //Show matches that we can send to
                }
            }
            .frame(width: screenWidth * 0.9)
            Spacer()
        }
    }
    
    var postButton: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.black)
            
            RoundedRectangle(cornerRadius: 10).stroke()
                .foregroundColor(.buttonPrimary)
            
            HStack {
                Text("Send")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Image(systemName: "paperplane")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
        .frame(width: screenWidth * 0.9, height: screenHeight * 0.05)
    }
}
