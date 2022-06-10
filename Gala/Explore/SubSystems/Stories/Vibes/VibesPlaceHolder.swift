//
//  TestSnapchatExpand.swift
//  Gala
//
//  Created by Vaughn on 2022-01-27.
//

import SwiftUI
import OrderedCollections

struct VibesPlaceHolder: View {
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 2)
    
    @ObservedObject var viewModel: StoriesViewModel
    
    @State var selectedVibe: VibeCoverImage = VibeCoverImage(image: UIImage(), title: "")
    //@State var showAllForVibe = false
    
    var response: CGFloat = 0.3
    var dampingFactor: CGFloat = 0.9
    var blendDuration: CGFloat = 0.01
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "dot.radiowaves.up.forward")
                        .rotationEffect(.degrees(-90))
                        .foregroundColor(.primary)
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                    
                    Text("Vibes")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                    Spacer()
                }
                
                if viewModel.vibeImages.count == 0 {
                    VStack {
                        Spacer()
                        LoadingView()
                    }.frame(height: screenHeight * 0.25)
                }
                
                LazyVGrid(columns: columns, content: {

                    ForEach(viewModel.vibeImages) { vibe in
                        if selectedVibe.id == vibe.id {
                            VibeView(vibe: vibe)
                                .frame(width: (screenWidth * 0.95) * 0.48, height: (screenWidth * 0.95) * 0.48)
                        } else {
                            Button(action: {
                                //self.vibesDict = viewModel.vibesDict
                                withAnimation(.spring(response: response, dampingFraction: dampingFactor, blendDuration: blendDuration)) {
                                    //self.selectedVibe = vibe
                                    //self.showVibe = true
                                    if let users = viewModel.vibesDict[vibe.title] {
                                        viewModel.getVibeStoryImage(uid: users[0].uid, pid: users[0].posts[0].pid, vibeTitle: vibe.title)
                                        viewModel.currentVibe = users
                                        viewModel.currentStory = users[0].id
                                        viewModel.showVibeStory = true
                                    }
                                }
                            }){
                                VibeView(vibe: vibe)
                            }
                            .frame(width: (screenWidth * 0.95) * 0.48, height: (screenWidth * 0.95) * 0.48)
                        }
                    }
                })
            }
            .frame(width: screenWidth * 0.95)
        }
        .sheet(isPresented: $viewModel.showVibeStory, content: {
            InstaStoryView(storyData: viewModel)
        })
//        .fullScreenCover(isPresented: $showAllForVibe, content: {
//            StoryListView(show: $showAllForVibe, vibe: $selectedVibe, stories: viewModel.vibesDict)
//        })
    }
}

struct ColorStruct: Identifiable {
    let id = UUID()
    var color: Color?
}

struct VibeCover: View {
    @Binding var vibe: VibeCoverImage
    @Binding var selectedVibe: VibeCoverImage
    
    @Binding var scale: CGFloat
    @Binding var showVibe: Bool
    
    var animation: Namespace.ID
    
    var body: some View {
        ZStack {
            Image(uiImage: vibe.image)
                .resizable()
                .scaledToFill()
                //.frame(width: (screenWidth * 0.95) * 0.48, height: (screenWidth * 0.95) * 0.48)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 4)
                .foregroundColor(.buttonPrimary)
                .edgesIgnoringSafeArea(.all)
        }
        .matchedGeometryEffect(id: vibe.id, in: animation)
        .scaleEffect(showVibe && selectedVibe.id == vibe.id ? scale : 1)
        .frame(width: (screenWidth * 0.95) * 0.48, height: (screenWidth * 0.95) * 0.48)
        .opacity(showVibe && selectedVibe.id == vibe.id ? 0 : 1)
        .onTapGesture {
            withAnimation {
                self.showVibe = true
                self.selectedVibe = vibe
            }
        }
    }
}
