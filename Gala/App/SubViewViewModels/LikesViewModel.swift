//
//  LikesViewModel.swift
//  Gala
//
//  Created by Vaughn on 2022-03-18.
//

import Foundation
import Combine

class LikesViewModel: SmallUserViewModelProtocol {
    
    private var cancellables: [AnyCancellable] = []
    
    init() {}
    
    func likeUser(with id: String) {
        LikesService.shared.likeUser(uid: id)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("LikesViewModel: Failed to like user with id -> \(id)")
                    print("LikesViewModel-err: \(e)")
                case .finished:
                    print("LikesViewModel: Successfully likes user with id -> \(id)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)

    }
    
    func unLikeUser(with id: String) {
        LikesService.shared.unLikeUser(uid: id)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("LikesViewModel: Failed to unlike user w/ id -> \(id)")
                    print("LikesViewModel-err: \(e)")
                case .finished:
                    print("LikesViewModel: Successfully unliked user w/ id -> \(id)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
