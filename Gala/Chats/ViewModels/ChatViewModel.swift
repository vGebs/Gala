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
    
    @Published var snaps: [Snap]?
    
    init(snaps: [Snap]?) {
        self.snaps = snaps
    }
    
    
}
