//
//  MatchesContainer.swift
//  Gala
//
//  Created by Vaughn on 2022-02-04.
//

import Combine
import FirebaseFirestore

class MatchesContainer: ObservableObject {
    
    static let shared = MatchesContainer()
    
    private let db = Firestore.firestore()
    
    @Published var matchIDs: [String] = []
    
    private init() {
        observeMatches()
    }
    
    private func observeMatches() {
        db.collection("Matches")
            .whereField("matched", arrayContains: String(AuthService.shared.currentUser!.uid))
            .addSnapshotListener { documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("Error fetching document: \(error!)")
                    return
                }

                documentSnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        if let uids = data["matched"] as? [String] {
                            for uid in uids {
                                if uid != AuthService.shared.currentUser!.uid {
                                    print("Matches: \(uid)")
                                    DispatchQueue.main.async {
                                        self.matchIDs.append(uid)
                                    }
                                }
                            }
                        }
                    }
                })
            }
    }
}
