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
                
                VStack {
                    ZStack {
                        if let story = bundle.posts[index] {
                            if story.storyImage != nil {
                                Image(uiImage: story.storyImage!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                //show placeholder
                            }
                            
                            next_prevView
                        }
                    }
                    if mode == .match {
                        textfield_camButton
                    } else {
                        Button(action: {
                            //like user
                            if bundle.liked {
                                storyData.unLikePost(uid: bundle.uid, pid: bundle.posts[index].pid)
                            } else {
                                storyData.likePost(uid: bundle.uid, pid: bundle.posts[index].pid)
                            }
                        }){
                            if bundle.liked {
                                unlikeButton
                            } else {
                                likeButton
                            }
                        }
                    }
                }
                
                VStack {
                    progressView
                    
                    //profileHeader
                    HStack(spacing: 13) {
                        if bundle.profileImg != nil {
                            ZStack{
                                Image(uiImage: bundle.profileImg!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: screenWidth / 10, height: screenWidth / 10)
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                                
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke()
                                    .foregroundColor(.buttonPrimary)
                                    .frame(width: screenWidth / 10, height: screenWidth / 10)
                            }
                        } else {
                            ZStack{
                                CircularLoadingView()
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke()
                                    .foregroundColor(.buttonPrimary)
                                    .frame(width: screenWidth / 10, height: screenWidth / 10)

                            }
                        }
                        
                        VStack {
                            if mode == .vibe {
                                HStack {
                                    Text("\(bundle.name), \(bundle.birthdate.ageString())")
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            } else {
                                HStack {
                                    Text(bundle.name)
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                            
                            HStack{
                                if let story = bundle.posts[index] {
                                    Text(secondsToHoursMinutesSeconds_(Int(story.pid.timeIntervalSinceNow)))
                                        .font(.system(size: 13, weight: .light, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                storyData.showMatchStory = false
                                storyData.showVibeStory = false
//                                storyData.currentVibe = []
//                                storyData.currentStory = ""
                            }
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                        })
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
                    
                    if timerProgress < CGFloat(bundle.posts.count) {
                        timerProgress += 0.003
                    }else {
                        updatingStory()
                    }
                }
            }
        }
    }
    
    var unlikeButton: some View {
        HStack {
            ZStack{
                Capsule().stroke()
                    .frame(width: screenWidth * 0.95, height: screenHeight * 0.045)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Unlike")
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
        }
        .offset(y: -2)
        .padding(.horizontal, 5)
    }
    
    var likeButton: some View {
        HStack {
            ZStack{
                Capsule().stroke()
                    .frame(width: screenWidth * 0.95, height: screenHeight * 0.045)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Image(systemName: "heart")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Like")
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
        }
        .offset(y: -2)
        .padding(.horizontal, 5)
    }
    
    var textfield_camButton: some View {
        HStack {
            Capsule().stroke()
                .frame(width: screenWidth * 0.8, height: screenHeight * 0.045)
                .foregroundColor(.accent)
            
            Spacer()
            Button(action: {}){
                ZStack{
                    Capsule().stroke()
                        .frame(width: screenWidth * 0.15, height: screenHeight * 0.045)
                        .foregroundColor(.accent)
                    Image(systemName: "camera")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
                
            }
        }
        .offset(y: -2)
        .padding(.horizontal, 5)
    }
    
    var progressView: some View {
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
    }
    
//    var profileHeader: some View {
//
//    }
    
    var next_prevView: some View {
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
    }
    
    private func updatingStory(forward: Bool = true){
        
        switch mode {
        case .vibe:
            updateVibeStory(forward)
        case .match:
            updateMatchStory(forward)
        }
    }
    
    private func updateVibeStory(_ forward: Bool) {
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
    
    private func updateMatchStory(_ forward: Bool) {
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
    
    private func getAngle(proxy: GeometryProxy) -> Angle {
        //converting offset into 45 degree rotation
        let progress = proxy.frame(in: .global).minX / proxy.size.width
        
        let rotationAngle: CGFloat = 45
        let degress = rotationAngle * progress
        return Angle(degrees: Double(degress))
    }
    
    private func secondsToHoursMinutesSeconds_(_ seconds: Int) -> String { //(Int, Int, Int)
        
        if abs(((seconds % 3600) / 60)) == 0 {
            let secondString = "\(abs((seconds % 3600) / 60))s"
            return secondString
        } else if abs((seconds / 3600)) == 0 {
            let minuteString = "\(abs((seconds % 3600) / 60))m"
            return minuteString
        } else if abs(seconds / 3600) < 24{
            let hourString = "\(abs(seconds / 3600))h"
            return hourString
        } else {
            let dayString = "\(abs(seconds / 86400))d"
            return dayString
        }
    }
}
