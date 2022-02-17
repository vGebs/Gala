//
//  SendViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-09-23.
//

import SwiftUI
import Combine

protocol SendViewModelProtocol {
    var vibes: [String] { get }

    
    func send(pic: UIImage)
    func postStory(_ pic: UIImage)
    func sendPic(to: String, _ pic: UIImage)
}

class SendViewModel: ObservableObject, SendViewModelProtocol {
    
    @Published var selectedMatch: String = ""
    @Published var selectedVibe: String = ""
    @Published var currentDay: String?
    @Published var currentPeriod: String?
    
    @Published private(set) var vibes: [String] = []
    
    private var cancellables: [AnyCancellable] = []
    
    init() {
        currentDay = Date().dayOfWeek()!
    }
    
    func getPostableVibes() {
        let day = Date().dayOfWeek()!
        let period = getTimeOfDay()
        currentPeriod = period
        VibesService.shared.getPostableVibes(dayOfWeek: day, period: period)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("SendViewModel: Failed to fetch postable vibes")
                    print("SendViewModel-Error: \(err.localizedDescription)")
                case .finished:
                    print("SendViewModel: Successfully fetched postable vibes")
                }
            } receiveValue: { [weak self] vibes in
                self?.vibes = vibes
            }
            .store(in: &self.cancellables)
    }
    
    func getTimeOfDay() -> String {
        let date = Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let hour = calendar.component(.hour, from: date)

        if hour >= 5 && hour < 12 {
            return "Morning"
        } else if hour >= 12 && hour < 17 {
            return "Afternoon"
        } else if hour >= 17 && hour < 22 {
            return "Evening"
        } else if hour >= 22 {
            return "Night"
        } else if hour < 5 {
            return "Night"
        }
        return ""
    }
    
    func send(pic: UIImage) {
        if selectedVibe != "" {
            //Post Story
            postStory(pic)
        } else if selectedMatch != "" {
            //sendPic to
            sendPic(to: selectedMatch, pic)
        }
    }
    
    internal func sendPic(to: String, _ pic: UIImage) {
        SnapService.shared.sendSnap(to: to, img: pic)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("SendViewModel: Failed to send snap")
                    print("SendViewModel-err: \(e)")
                case .finished:
                    print("SendViewModel: Successfully sent snap")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    internal func postStory(_ pic: UIImage) {
        print("Selected: \(self.selectedVibe)")
        StoryService.shared.postStory(postID_date: Date(), vibe: selectedVibe, asset: pic)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("SendViewModel: Failed to post story")
                    print("SendViewModel-error: \(err)")
                case .finished:
                    print("SendViewModel: Successfully posted story")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
