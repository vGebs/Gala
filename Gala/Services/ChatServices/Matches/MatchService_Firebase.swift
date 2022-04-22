//
//  MatchService.swift
//  Gala
//
//  Created by Vaughn on 2022-02-09.
//

import Combine
import FirebaseFirestore

class MatchService_Firebase {
    private var cancellables: [AnyCancellable] = []
    private let db = Firestore.firestore()

    static let shared = MatchService_Firebase()
    private init() {}

    func getMatches() -> AnyPublisher<[Match], Error> {
        return Future<[Match], Error> { promise in
            self.db.collection("Matches")
                .whereField("matched", arrayContains: String(AuthService.shared.currentUser!.uid))
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("MatchService: Failed to fetch matches")
                        print("MatchService-err: \(error)")
                        promise(.failure(error))
                    } else {
                        var matches: [Match] = []
                        
                        for doc in snapshot!.documents {
                            let matchArray = doc.data()["matched"] as? [String]
                            let timestamp = doc.data()["time"] as? Timestamp
                            
                            if let matchedDate = timestamp?.dateValue() {
                                if let matchArray = matchArray {
                                    for match in matchArray {
                                        if match != AuthService.shared.currentUser?.uid {
                                            print("Match: \(match)")
                                            let m = Match(matchedUID: match, timeMatched: matchedDate)
                                            matches.append(m)
                                        }
                                    }
                                }
                            }
                        }
                        promise(.success(matches))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    func observeMatches(fromDate: Timestamp, existingMatches: [Match], completion: @escaping ([Match]) -> Void) {
        db.collection("Matches")
            .whereField("matched", arrayContains: String(AuthService.shared.currentUser!.uid))
            .whereField("time", isGreaterThan: fromDate)
            .order(by: "time")
            .addSnapshotListener { documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("MatchService: Error fetching document: \(error!)")
                    return
                }
                
                var final: [Match] = existingMatches

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
