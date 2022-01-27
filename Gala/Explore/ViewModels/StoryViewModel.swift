//
//  StoryViewModel.swift
//  Gala
//
//  Created by Vaughn on 2022-01-25.
//

import Combine
import SwiftUI

protocol StoryViewModelProtocol {
    func fetchStory()
    func fetchProfileImg()
    func likePost()
    func reportPost()
}

class StoryViewModel: ObservableObject, StoryViewModelProtocol {
    
    private(set) var name: String
    
    private var pid: Date
    private var uid: String

    @Published private(set) var img: UIImage?
    @Published private(set) var profileImg: UIImage?
    @Published private(set) var age: String = ""
    @Published private(set) var timeSincePost: String = ""
    
    private var cancellables: [AnyCancellable] = []
    
    init(pid: Date, name: String, birthdate: Date, uid: String) {
        self.name = name
        self.uid = uid
        self.pid = pid
        
        fetchStory()
        fetchProfileImg()
        
        self.age = birthdate.ageString()
        self.timeSincePost = secondsToHoursMinutesSeconds(Int(pid.timeIntervalSinceNow))
    }
    
    func fetchStory() {
        StoryContentService.shared.getStory(uid: uid, storyID: pid)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("StoryViewModel: Failed to fetch story")
                    print("StoryViewModel-err: \(err)")
                case .finished:
                    print("StoryViewModel: Sucessfully fetched story")
                }
            } receiveValue: { [weak self] img in
                if let img = img {
                    self?.img = img
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchProfileImg() {
        ProfileImageService.shared.getProfileImage(id: uid, index: "0")
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("StoryViewModel: Failed to fetch profile image")
                    print("StoryViewModel-err: \(err)")
                case .finished:
                    print("StoryViewModel: Sucessfully fetched profile image")
                }
            } receiveValue: { [weak self] img in
                if let img = img {
                    self?.profileImg = img
                }
            }
            .store(in: &cancellables)
    }
    
    func likePost() {
        LikesService.shared.likePost(uid: self.uid, postID: self.pid)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("StoryViewModel: Failed to like post")
                    print("StoryViewModel-err: \(err)")
                case .finished:
                    print("StoryViewModel: Successfully liked post")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func reportPost() {
        
    }
    
    // extract this method and add it to date.
    // will need to input a date and then from there get seconds and then we can get the output
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> String { //(Int, Int, Int)
        
//        print(String((seconds % 86400) / 3600) + " hours")
//        print(String((seconds % 3600) / 60) + " minutes")
//        print(String((seconds % 3600) % 60) + " seconds")
        
        if abs(((seconds % 3600) / 60)) == 0 {
            let secondString = "\(abs((seconds % 3600) / 60))s"
            return secondString
        } else if abs((seconds / 3600)) == 0 {
            let minuteString = "\(abs((seconds % 3600) / 60))m"
            return minuteString
        } else {
            let hourString = "\(abs(seconds / 3600))h"
            return hourString
        }
        
        //return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
