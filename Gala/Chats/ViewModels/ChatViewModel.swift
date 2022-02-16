//
//  ChatViewModel.swift
//  Gala
//
//  Created by Vaughn on 2022-02-10.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messageText = ""
    
    private var cancellables: [AnyCancellable] = []
    
    func sendMessage(toUID: String) {
        //make sure there is at least one character before sending
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !messageText.isEmpty && trimmed.count > 0{
            ChatService.shared.sendMessage(message: messageText, toID: toUID)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("ChatViewModel: Failed to send messgae")
                        print("ChatsViewModel-err: \(e)")
                    case .finished:
                        print("ChatsViewModel: Successfully sent message to -> \(toUID)")
                    }
                } receiveValue: { [weak self] _ in
                    self?.messageText = ""
                }
                .store(in: &cancellables)
        }
    }
}
