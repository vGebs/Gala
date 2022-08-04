//
//  SendVieww.swift
//  Gala
//
//  Created by Vaughn on 2021-09-22.
//

import SwiftUI

struct SendView: View {
    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var yCoordinate: CGFloat
    @Binding var isPresented: Bool
    @ObservedObject var camera: CameraViewModel
    @ObservedObject var viewModel: SendViewModel
    @ObservedObject var chatsViewModel: ChatsViewModel = AppState.shared.chatsVM!
    
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
                    
                    var caption: Caption?
                    
                    if text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                        caption = Caption(captionText: text, textBoxHeight: height, yCoordinate: yCoordinate)
                    }
                    
                    if let img = camera.image {
                        self.viewModel.send(pic: img, caption: caption)
                        
                    } else if let vidURLPath = camera.videoURL {
                        self.viewModel.send(vid: URL(fileURLWithPath: vidURLPath), caption: caption)
                    }
                    
                    self.camera.deleteAsset()
                    self.viewModel.selectedVibe = ""
                    self.viewModel.selectedMatch = ""
                    self.isPresented = false
                }){
                    postButton
                }
                .disabled(viewModel.selectedVibe == "" && viewModel.selectedMatch == "")
                .opacity(viewModel.selectedVibe != "" || viewModel.selectedMatch != "" ? 1 : 0.4)
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
                PostSelector(selected: viewModel.selectedVibe, text: viewModel.vibes[i])
                    .frame(width: screenWidth * 0.9)
                    .onTapGesture {
                        if viewModel.selectedVibe == viewModel.vibes[i] {
                            viewModel.selectedVibe = ""
                        } else {
                            viewModel.selectedVibe = viewModel.vibes[i]
                            viewModel.selectedMatch = ""
                        }
                    }
            }
            
            PostSelector(selected: viewModel.selectedVibe, text: "Add a private story")
                .frame(width: screenWidth * 0.9)
                .onTapGesture {
                    if viewModel.selectedVibe == "Add a private story" {
                        viewModel.selectedVibe = ""
                    } else {
                        viewModel.selectedVibe = "Add a private story"
                        viewModel.selectedMatch = ""
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
            }
            .frame(width: screenWidth * 0.9)
            
            ForEach(chatsViewModel.matches) { match in
                //Show matches that we can send to
                SendToSelector(user: match, selected: $viewModel.selectedMatch, distanceCalculator: DistanceCalculator(lng: match.uc.searchRadiusComponents.coordinate.lng, lat: match.uc.searchRadiusComponents.coordinate.lat))
                    .onTapGesture {
                        if viewModel.selectedMatch == match.uc.userBasic.uid {
                            viewModel.selectedMatch = ""
                        } else {
                            viewModel.selectedMatch = match.uc.userBasic.uid
                            viewModel.selectedVibe = ""
                        }
                    }
            }
            
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
