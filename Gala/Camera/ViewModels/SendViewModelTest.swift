//
//  SendViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-09-09.
//

import Combine
import SwiftUI

class SendViewModelTest: ObservableObject {
    
    private var storyService: StoryService = StoryService.shared
    private var storyMetaService: StoryMetaService = StoryMetaService.shared
    private var currentUserCore: UserCore = UserCoreService.shared.currentUserCore!
    private var cancellables: [AnyCancellable] = []
    
    init() {}
    
    func postStory() {

        let date = Date()
        storyService.postStory(postID_date: date, asset: UIImage())
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("SendViewModel: Failed to post story")
                    print("SendViewModel-Error: \(err.localizedDescription)")
                case .finished:
                    print("SendViewModel: Successfully posted story with ID: \(date)")
                }
            } receiveValue: { _ in }
            .store(in: &self.cancellables)
    }
    
    func getMyStories() {
        storyMetaService.getMyStories()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("SendViewModel: Failed to get recents")
                    print("SendViewModel-Error: \(err.localizedDescription)")
                case .finished:
                    print("SendViewModel: Successfully got recents")
                }
            } receiveValue: { storyIds in
                for id in storyIds {
                    print("ID: \(id)")
                }
            }.store(in: &self.cancellables)
    }
    
    func deleteStory() {
        let id = storyService.postIDs[0]
        storyService.deleteStory(storyID: id)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("SendViewModel: Failed to delete post w/ id: \(id)")
                    print("SendViewModel-Error: \(err.localizedDescription)")
                case .finished:
                    print("SendViewModel: Successfully deleted post w/ id: \(id)")
                }
            } receiveValue: {[unowned self] _ in
                for id in self.storyService.postIDs {
                    print("ID11: \(id)")
                }
            }
            .store(in: &self.cancellables)
    }
    
    func getTimeOfDay() {
        VibesService.shared.getPostableVibes(dayOfWeek: "Friday", period: "Afternoon")
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink{ completion in
                switch completion {
                case .failure(let err):
                    print("SendViewModel: Failed to get titles for the day and period")
                    print("SendViewModel-Error: \(err.localizedDescription)")
                case .finished:
                    print("SendViewModel: Successfully fetched titles for the day and period")
                }
            } receiveValue: { titles in
                print(titles)
            }
            .store(in: &self.cancellables)
    }
}
