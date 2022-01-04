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
    
    func postStory(pic: UIImage)
    func send()
}

class SendViewModel: ObservableObject, SendViewModelProtocol {
    
    @Published var selected: String = ""
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
    
    func postStory(pic: UIImage) {
        print("Selected: \(self.selected)")
        StoryService.shared.postStory(postID_date: Date(), asset: pic)
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
    
    func send() {
        
    }
}
