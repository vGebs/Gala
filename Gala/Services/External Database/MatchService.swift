//
//  MatchService.swift
//  Gala
//
//  Created by Vaughn on 2022-02-09.
//

import Combine
import FirebaseFirestore

class MatchService {
    private var cancellables: [AnyCancellable] = []
    private let db = Firestore.firestore()

    static let shared = MatchService()
    private init() {}

    func getMatches() -> AnyPublisher<[String], Error> {
        return Future<[String], Error> { promise in
            self.db.collection("Matches")
                .whereField("matched", arrayContains: String(AuthService.shared.currentUser!.uid))
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("MatchService: Failed to fetch matches")
                        print("MatchService-err: \(error)")
                        promise(.failure(error))
                    } else {
                        var matches: [String] = []
                        
                        for doc in snapshot!.documents {
                            let matchArray = doc.data()["matched"] as? [String]
                            if let matchArray = matchArray {
                                for match in matchArray {
                                    if match != AuthService.shared.currentUser?.uid {
                                        print("Match: \(match)")
                                        matches.append(match)
                                    }
                                }
                            }
                        }
                        promise(.success(matches))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    func observeMatches(completion: @escaping ([Match]) -> Void) {
        db.collection("Matches")
            .whereField("matched", arrayContains: String(AuthService.shared.currentUser!.uid))
            .order(by: "time")
            .addSnapshotListener { documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("MatchService: Error fetching document: \(error!)")
                    return
                }
                
                var final: [Match] = []

                documentSnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        let timestamp = data["time"] as? Timestamp
                        
                        if let matchDate = timestamp?.dateValue(){
                            if let uids = data["matched"] as? [String] {
                                for uid in uids {
                                    if uid != AuthService.shared.currentUser!.uid {
                                        let match = Match(matchedUID: uid, timeMatched: matchDate)
                                        final.append(match)
                                        print("MatchService: Added new match: \(uid)")
                                    }
                                }
                            }
                        }
                    }
                })
                completion(final)
            }
    }
}
