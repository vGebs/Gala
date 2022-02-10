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
                .whereField("matched", arrayContains: AuthService.shared.currentUser?.uid)
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
}
