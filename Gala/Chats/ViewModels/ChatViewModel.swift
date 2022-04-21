//
//  ChatViewModel.swift
//  Gala
//
//  Created by Vaughn on 2022-02-10.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {

    private var cancellables: [AnyCancellable] = []

    @Published var messages: [Message]
    
    init(uid: String?) {
        if let uid = uid {
            if let msgs = MessageService_CoreData.shared.getAllMessages(fromUserWith: uid) {
                self.messages = msgs
            } else {
                messages = []
            }
        } else {
            messages = []
        }        
    }
}
