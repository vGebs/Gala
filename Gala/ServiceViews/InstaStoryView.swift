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
    case demoMatchStories
    case demoVibeStories
}

struct InstaStoryView: View {
    @ObservedObject var storyData: StoriesViewModel
    var mode: StoryMode = .vibe
    
    var body: some View {
        if storyData.showVibeStory || storyData.showMatchStory {
            TabView(selection: $storyData.currentStory) {
                ForEach(mode == .vibe ? $storyData.currentVibe : $storyData.matchedStories) { $bundle in
                    StoryCardView(userPostSimple: $bundle, storyVM: storyData, mode: mode)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
        } else if storyData.showDemoStory {
            TabView(selection: $storyData.currentStory) {
                ForEach($storyData.demoMatchedStories) { $bundle in
                    StoryCardView(userPostSimple: $bundle, storyVM: storyData, mode: mode)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
        } else if storyData.showDemoVibeStory {
            TabView(selection: $storyData.currentStory) {
                ForEach($storyData.currentVibe) { $bundle in
                    StoryCardView(userPostSimple: $bundle, storyVM: storyData, mode: mode)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
        }
    }
}

struct StoryCardView: View {
    @Binding var userPostSimple: UserPostSimple
    @ObservedObject var storyVM: StoriesViewModel
    
    @State var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    @State var timerProgress: CGFloat = 0 {
        didSet {
            let index = Int(timerProgress)
            
            if index < userPostSimple.posts.count {
                if userPostSimple.posts[index].storyImage == nil {
                    switch mode {
                    case .vibe:
                        storyVM.getVibeStoryImage(uid: userPostSimple.uid, pid: userPostSimple.posts[index].pid, vibeTitle: userPostSimple.posts[index].title)
                    case .match:
                        storyVM.getMatchStoryImage(uid: userPostSimple.uid, pid: userPostSimple.posts[index].pid)
                    case .demoMatchStories:
                        storyVM.getDemoImage()
                    case .demoVibeStories:
                        storyVM.getDemoImage()
                    }
                }
                
                switch mode {
                case .match:
                    if index > 0 && (index != userPostSimple.posts.count){ //
                        userPostSimple.posts[index - 1].storyImage = nil
                    }
                case .vibe:
                    if index > 0 {
                        userPostSimple.posts[index - 1].storyImage = nil
                    }
                case .demoMatchStories:
                    print("")
                case .demoVibeStories:
                    print("")
                }
            }
        }
    }
    
    var mode: StoryMode
    
    var body: some View {
        //For 3d rotation
        GeometryReader { proxy in
            ZStack {
                //Getting current index
                let index = min(Int(timerProgress), userPostSimple.posts.count - 1)
                
                VStack {
                    ZStack {
                        if let story = userPostSimple.posts[index] {
                            if story.storyImage != nil {
                                Image(uiImage: story.storyImage!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                if let caption = story.caption {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(.black)
                                            .opacity(0.6)
                                        Text(caption.captionText)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .regular, design: .rounded))
                                    }
                                    .frame(height: caption.textBoxHeight)
                                    .position(x: screenWidth / 2, y: caption.yCoordinate)
                                }
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
                            if mode != .demoMatchStories {
                                if userPostSimple.liked {
                                    storyVM.unLikePost(uid: userPostSimple.uid, pid: userPostSimple.posts[index].pid)
                                } else {
                                    storyVM.likePost(uid: userPostSimple.uid, pid: userPostSimple.posts[index].pid)
                                }
                            }
                        }){
                            if userPostSimple.liked {
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
                        if userPostSimple.profileImg != nil {
                            ZStack{
                                if mode == .demoMatchStories {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .foregroundColor(.primary)
                                        .frame(width: screenWidth / 14, height: screenWidth / 14)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                } else {
                                    Image(uiImage: userPostSimple.profileImg!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: screenWidth / 10, height: screenWidth / 10)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                }
                                
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
                                    Text("\(userPostSimple.name), \(userPostSimple.birthdate.ageString())")
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            } else {
                                HStack {
                                    Text(userPostSimple.name)
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                            
                            HStack{
                                if let story = userPostSimple.posts[index] {
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
                                storyVM.showMatchStory = false
                                storyVM.showVibeStory = false
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
                if storyVM.currentStory == userPostSimple.id {
                    
                    if timerProgress < CGFloat(userPostSimple.posts.count) {
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
            ForEach(userPostSimple.posts.indices) { i in
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
            //go to previous image
            Rectangle()
                .fill(.black.opacity(0.01))
                .onTapGesture {
                    //if we are at the first image
                    if (timerProgress - 1) < 0 {
                        updatingStory(forward: false)
                    } else { //if we are not at first image, go back
                        //we are going back,
                        //so we need to check to make sure we are not on the last story for that user,
                        
                        
                        
                        let currentIndex = Int(timerProgress)
                        
                        //if we are on the last story for that user
                        //  we just grab the previous image from core data
                        if currentIndex == userPostSimple.posts.count - 1 {
                            
                            switch mode {
                            case .vibe:
                                storyVM.getVibeStoryImage(uid: userPostSimple.uid, pid: userPostSimple.posts[currentIndex].pid, vibeTitle: userPostSimple.posts[currentIndex].title)
                            case .match:
                                storyVM.getMatchStoryImage(uid: userPostSimple.uid, pid: userPostSimple.posts[currentIndex].pid)
                            case .demoMatchStories:
                                print("")
                            case .demoVibeStories:
                                print("")
                            }
                            
                        } else {
                            //if we are not on the last story for that user
                            //  we set the current img to nil and grab the previous story
                            switch mode {
                            case .vibe:
                                storyVM.getVibeStoryImage(uid: userPostSimple.uid, pid: userPostSimple.posts[currentIndex].pid, vibeTitle: userPostSimple.posts[currentIndex].title)
                                userPostSimple.posts[currentIndex].storyImage = nil

                            case .match:
                                storyVM.getMatchStoryImage(uid: userPostSimple.uid, pid: userPostSimple.posts[currentIndex].pid)
                                userPostSimple.posts[currentIndex].storyImage = nil

                            case .demoMatchStories:
                                print("")
                            case .demoVibeStories:
                                print("")
                            }
                        }
                        
                        timerProgress = CGFloat(Int(timerProgress - 1))
                    }
                }
            
            //go to next image
            Rectangle()
                .fill(.black.opacity(0.01))
                .onTapGesture {
                    
                    //Checking and updating to next
                    if (timerProgress + 1) > CGFloat(userPostSimple.posts.count) {
                        //update to next bundle
                        updatingStory()
                    } else {
                        
                        let currentIndex = Int(timerProgress)
                        
                        //we need to get the next image and make the current story nil
                        
                        switch mode {
                        case .vibe:
                            storyVM.getVibeStoryImage(uid: userPostSimple.uid, pid: userPostSimple.posts[currentIndex].pid, vibeTitle: userPostSimple.posts[currentIndex].title)
                            userPostSimple.posts[currentIndex].storyImage = nil

                        case .match:
                            storyVM.getMatchStoryImage(uid: userPostSimple.uid, pid: userPostSimple.posts[currentIndex].pid)
                            userPostSimple.posts[currentIndex].storyImage = nil

                        case .demoMatchStories:
                            print("")
                        case .demoVibeStories:
                            print("")
                        }
                        
                        
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
        case .demoMatchStories:
            updateDemoStory(forward)
        case .demoVibeStories:
            updateVibeStory(forward)
        }
    }
    
    private func updateDemoStory(_ forward: Bool) {
        let index = min(Int(timerProgress), userPostSimple.posts.count - 1)
        
        let story = userPostSimple.posts[index]
        
        if !forward {
            //moving index backward
            //else set timer to 0
            
            if let first = storyVM.matchedStories.first, first.id != userPostSimple.id {
                let bundleIndex = storyVM.demoMatchedStories.firstIndex { currentBundle in
                    return userPostSimple.id == currentBundle.id
                } ?? 0
                
                withAnimation {
                    storyVM.currentStory = storyVM.demoMatchedStories[bundleIndex - 1].id
                }
                
            } else {
                timerProgress = 0
            }
            
            return
        }
        
        //checking if its the last
        if let last = userPostSimple.posts.last, last.id == story.id {
            //if there is another story, move to it
            // else, closing view
            if let lastBundle = storyVM.demoMatchedStories.last, lastBundle.id == userPostSimple.id {
                withAnimation {
                    storyVM.showDemoStory = false
                }
            } else {
                //updating to next bundle
                let bundleIndex = storyVM.demoMatchedStories.firstIndex { currentBundle in
                    return userPostSimple.id == currentBundle.id
                } ?? 0
                
                withAnimation {
                    storyVM.currentStory = storyVM.demoMatchedStories[bundleIndex + 1].id
                }
            }
        }
    }
    
    private func updateVibeStory(_ forward: Bool) {
        let index = min(Int(timerProgress), userPostSimple.posts.count - 1)
        
        let story = userPostSimple.posts[index]
        
        if !forward {
            //moving index backward
            //else set timer to 0
            
            if let first = storyVM.currentVibe.first, first.id != userPostSimple.id {
                let bundleIndex = storyVM.currentVibe.firstIndex { currentBundle in
                    return userPostSimple.id == currentBundle.id
                } ?? 0
                
                withAnimation {
                    storyVM.currentStory = storyVM.currentVibe[bundleIndex - 1].id
                }
                
            } else {
                timerProgress = 0
            }
            
            return
        }
        
        //checking if its the last
        if let last = userPostSimple.posts.last, last.id == story.id {
            //if there is another story, move to it
            // else, closing view
            if let lastBundle = storyVM.currentVibe.last, lastBundle.id == userPostSimple.id {
                withAnimation {
                    if mode == .demoVibeStories {
                        storyVM.showDemoVibeStory = false
                    } else {
                        storyVM.showVibeStory = false
                    }
                }
            } else {
                //updating to next bundle
                let bundleIndex = storyVM.currentVibe.firstIndex { currentBundle in
                    return userPostSimple.id == currentBundle.id
                } ?? 0
                
                withAnimation {
                    storyVM.currentStory = storyVM.currentVibe[bundleIndex + 1].id
                }
            }
        }
    }
    
    private func updateMatchStory(_ forward: Bool) {
        let index = min(Int(timerProgress), userPostSimple.posts.count - 1)
        
        let story = userPostSimple.posts[index]
        
        if !forward {
            //moving index backward
            //else set timer to 0
            
            if let first = storyVM.matchedStories.first, first.id != userPostSimple.id {
                let bundleIndex = storyVM.matchedStories.firstIndex { currentBundle in
                    return userPostSimple.id == currentBundle.id
                } ?? 0
                
                withAnimation {
                    storyVM.currentStory = storyVM.matchedStories[bundleIndex - 1].id
                }
                
            } else {
                timerProgress = 0
            }
            
            return
        }
        
        //checking if its the last
        if let last = userPostSimple.posts.last, last.id == story.id {
            //if there is another story, move to it
            // else, closing view
            if let lastBundle = storyVM.matchedStories.last, lastBundle.id == userPostSimple.id {
                withAnimation {
                    storyVM.showMatchStory = false
                }
            } else {
                //updating to next bundle
                let bundleIndex = storyVM.matchedStories.firstIndex { currentBundle in
                    return userPostSimple.id == currentBundle.id
                } ?? 0
                
                withAnimation {
                    storyVM.currentStory = storyVM.matchedStories[bundleIndex + 1].id
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
