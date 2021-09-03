//
//  ChatsViewModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Foundation
import Combine

class ChatsViewModel: ObservableObject {
    private var cancellables: [AnyCancellable] = []
    func doo() {
        LikesService.shared.getPeopleILiked()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("ChatsViewModel: Error getting people I like")
                    print("ChatsViewModel-Error: \(error.localizedDescription)")
                case .finished:
                    print("ChatsViewModel: Finished getting users i like")
                }
            } receiveValue: { _ in
                
            }.store(in: &self.cancellables)
    }
}
