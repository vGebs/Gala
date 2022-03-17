//
//  InstaStoryView.swift
//  Gala
//
//  Created by Vaughn on 2022-03-16.
//

import SwiftUI

enum StoryMode {
    case match
    case vibe
}

struct InstaStoryView: View {
    @ObservedObject var storyData: StoriesViewModel
    var mode: StoryMode = .vibe
    
    var body: some View {
        if storyData.showVibeStory || storyData.showMatchStory {
            TabView(selection: $storyData.currentStory) {
                ForEach(mode == .vibe ? $storyData.currentVibe : $storyData.matchedStories) { $bundle in
                    StoryCardView(bundle: $bundle, storyData: storyData, mode: mode)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
        }
    }
}

struct StoryCardView: View {
    @Binding var bundle: UserPostSimple
    @ObservedObject var storyData: StoriesViewModel
    
    @State var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State var timerProgress: CGFloat = 0
        
    var mode: StoryMode
    
    var body: some View {
        //For 3d rotation
        GeometryReader { proxy in
            ZStack {
                //Getting current index
                
                let index = min(Int(timerProgress), bundle.posts.count - 1)
                
                if let story = bundle.posts[index] {
                    if story.storyImage != nil {
                        Image(uiImage: story.storyImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        //show placeholder
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .overlay(
                HStack {
                    Rectangle()
                        .fill(.black.opacity(0.01))
                        .onTapGesture {
                            if (timerProgress - 1) < 0 {
                                updatingStory(forward: false)
                            } else {
                                timerProgress = CGFloat(Int(timerProgress - 1))
                            }
                        }
                    
                    Rectangle()
                        .fill(.black.opacity(0.01))
                        .onTapGesture {
                            
                            //Checking and updating to next
                            if (timerProgress + 1) > CGFloat(bundle.posts.count) {
                                //update to next bundle
                                updatingStory()
                            } else {
                                timerProgress = CGFloat(Int(timerProgress + 1))
                            }
                        }
                }
            )
            .overlay(
                //Top Profile View
                HStack(spacing: 13) {
                    if bundle.profileImg != nil {
                        Image(uiImage: bundle.profileImg!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 35, height: 35)
                            .clipShape(Circle())
                    } else {
                        //show placeholder
                    }
                    
                    
                    Text(bundle.name)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            storyData.showMatchStory = false
                            storyData.currentVibe = []
                            storyData.currentStory = ""
                        }
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    })
                }
                    .padding()
                ,alignment: .topTrailing
            )
            //ProgressBar
            .overlay(
                HStack(spacing: 5){
                    ForEach(bundle.posts.indices) { i in
                        GeometryReader { proxy in
                            
                            let width = proxy.size.width
                            
                            //Getting progress by eliminating current index with progress
                            //Setting max to 1
                            //Setting min to 0
                            let progress = timerProgress - CGFloat(i)
                            let perfectProgress = min(max(progress, 0), 1)
                            
                            
                            Capsule()
                                .fill(.gray.opacity(0.5))
                                .overlay(
                                    Capsule()
                                        .fill(.white)
                                        .frame(width: width * perfectProgress)
                                    , alignment: .leading
                                )
                        }
                    }
                }
                .frame(height: 1.4)
                .padding(.horizontal)
                
                , alignment: .top
            )
            .rotation3DEffect(getAngle(proxy: proxy),
                              axis: (x: 0, y: 1, z: 0),
                              anchor: proxy.frame(in: .global).minX > 0 ? .leading : .trailing,
                              perspective: 2.5
            )
            .onAppear{
                timerProgress = 0
            }
            .onReceive(timer) { _ in
                if storyData.currentStory == bundle.id {
//                    if !bundle.isSeen {
//                        bundle.isSeen = true
//                    }
                    
                    if timerProgress < CGFloat(bundle.posts.count) {
                        timerProgress += 0.003
                    }else {
                        updatingStory()
                    }
                }
            }
        }
    }
    
    func updatingStory(forward: Bool = true){
        
        switch mode {
        case .vibe:
            updateVibeStory(forward)
        case .match:
            updateMatchStory(forward)
        }
    }
    
    func updateVibeStory(_ forward: Bool) {
        let index = min(Int(timerProgress), bundle.posts.count - 1)
        
        let story = bundle.posts[index]
        
        if !forward {
            //moving index backward
            //else set timer to 0
            
            if let first = storyData.currentVibe.first, first.id != bundle.id {
                let bundleIndex = storyData.currentVibe.firstIndex { currentBundle in
                    return bundle.id == currentBundle.id
                } ?? 0
                
                withAnimation {
                    storyData.currentStory = storyData.currentVibe[bundleIndex - 1].id
                }
                
            } else {
                timerProgress = 0
            }
            
            return
        }
        
        //checking if its the last
        if let last = bundle.posts.last, last.id == story.id {
            //if there is another story, move to it
            // else, closing view
            if let lastBundle = storyData.currentVibe.last, lastBundle.id == bundle.id {
                withAnimation {
                    storyData.showVibeStory = false
                }
            } else {
                //updating to next bundle
                let bundleIndex = storyData.currentVibe.firstIndex { currentBundle in
                    return bundle.id == currentBundle.id
                } ?? 0
                
                withAnimation {
                    storyData.currentStory = storyData.currentVibe[bundleIndex + 1].id
                }
            }
        }
    }
    
    func updateMatchStory(_ forward: Bool) {
        let index = min(Int(timerProgress), bundle.posts.count - 1)
        
        let story = bundle.posts[index]
        
        if !forward {
            //moving index backward
            //else set timer to 0
            
            if let first = storyData.matchedStories.first, first.id != bundle.id {
                let bundleIndex = storyData.matchedStories.firstIndex { currentBundle in
                    return bundle.id == currentBundle.id
                } ?? 0
                
                withAnimation {
                    storyData.currentStory = storyData.matchedStories[bundleIndex - 1].id
                }
                
            } else {
                timerProgress = 0
            }
            
            return
        }
        
        //checking if its the last
        if let last = bundle.posts.last, last.id == story.id {
            //if there is another story, move to it
            // else, closing view
            if let lastBundle = storyData.matchedStories.last, lastBundle.id == bundle.id {
                withAnimation {
                    storyData.showMatchStory = false
                }
            } else {
                //updating to next bundle
                let bundleIndex = storyData.matchedStories.firstIndex { currentBundle in
                    return bundle.id == currentBundle.id
                } ?? 0
                
                withAnimation {
                    storyData.currentStory = storyData.matchedStories[bundleIndex + 1].id
                }
            }
        }
    }
    
    func getAngle(proxy: GeometryProxy) -> Angle {
        //converting offset into 45 degree rotation
        let progress = proxy.frame(in: .global).minX / proxy.size.width
        
        let rotationAngle: CGFloat = 45
        let degress = rotationAngle * progress
        return Angle(degrees: Double(degress))
    }
}
