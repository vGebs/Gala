//
//  ChatsViewModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Foundation
import Combine
import FirebaseFirestore

class ChatsViewModel: ObservableObject {
    
    private var cancellables: [AnyCancellable] = []
    
    private let db = Firestore.firestore()
    
    @Published private(set) var matchIDs: [String] = []
    
    init() {
        observeMatches()
    }
    
    private func observeMatches()  {
        db.collection("Matches")
            .whereField("matched", arrayContains: String(AuthService.shared.currentUser!.uid))
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                documentSnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        
                        var final: [String] = []
                        
                        if let uids = data["matched"] as? [String] {
                            for uid in uids {
                                if uid != AuthService.shared.currentUser!.uid {
                                    print("Matches: \(uid)")
                                    //let temp = SmallUserViewModel(uid: uid)
                                    final.append(uid)
                                    print("ChatsViewModel: Added new match: \(uid)")
                                }
                            }
                        }
                        self?.matchIDs = final
                    }
                })
            }
    }
    
//    func doo() {
//        LikesService.shared.getPeopleILiked()
//            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
//            .sink { completion in
//                switch completion {
//                case .failure(let error):
//                    print("ChatsViewModel: Error getting people I like")
//                    print("ChatsViewModel-Error: \(error.localizedDescription)")
//                case .finished:
//                    print("ChatsViewModel: Finished getting users i like")
//                }
//            } receiveValue: { _ in
//                
//            }.store(in: &self.cancellables)
//    }
}
