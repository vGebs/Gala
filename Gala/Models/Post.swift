//
//  Post.swift
//  Gala
//
//  Created by Vaughn on 2022-03-29.
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftUI

class Post: Identifiable, ObservableObject {
    let id = UUID()
    let pid: Date
    let uid: String
    let title: String
    
    var storyImage: UIImage? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published private(set) var timeSincePost: String = ""

    private var cancellables: [AnyCancellable] = []
    
    deinit {
        print("Post Model: Deinitializing")
    }
    
    init(pid: Date, uid: String, title: String) {
        self.pid = pid
        self.title = title
        self.uid = uid
        
        StoryContentService.shared.getStory(uid: uid, storyID: pid)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("Post Model: Failed to fetch story with pid: \(pid)")
                    print("Post Model-err: \(err)")
                case .finished:
                    print("Post Model: Successfully fetched story with pid: \(pid)")
                }
            } receiveValue: { [weak self] img in
                if let img = img {
                    self?.storyImage = img
                }
            }.store(in: &cancellables)

        self.timeSincePost = secondsToHoursMinutesSeconds(Int(pid.timeIntervalSinceNow))
        
    }
    
    // extract this method and add it to date.
    // will need to input a date and then from there get seconds and then we can get the output
    private func secondsToHoursMinutesSeconds(_ seconds: Int) -> String { //(Int, Int, Int)
        
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
    }
}
