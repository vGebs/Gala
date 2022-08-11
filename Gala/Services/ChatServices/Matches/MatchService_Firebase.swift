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
                                            let m = Match(matchedUID: match, timeMatched: matchedDate, docID: doc.documentID)
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
    
    func observeMatches(completion: @escaping ([Match]) -> Void) { //fromDate: Timestamp,
        db.collection("Matches")
            .whereField("matched", arrayContains: String(AuthService.shared.currentUser!.uid))
            .addSnapshotListener { documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("MatchService: Error fetching document: \(error!)")
                    return
                }
                
                var finalMatches: [Match] = []
                
                documentSnapshot?.documentChanges.forEach({ change in
                    let data = change.document.data()
                    let timestamp = data["time"] as? Timestamp
                    
                    
                    if let matchDate = timestamp?.dateValue(){
                        if let uids = data["matched"] as? [String] {
                            for uid in uids {
                                if uid != AuthService.shared.currentUser!.uid {
                                    let match = Match(matchedUID: uid, timeMatched: matchDate, docID: change.document.documentID, changeType: change.type)
                                    finalMatches.append(match)
                                }
                            }
                        }
                    }
                })
                completion(finalMatches)
            }
    }
    
    func unMatchUser(with docID: String, and uid: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            self!.db.collection("Matches").document(docID).delete() { [weak self] err in
                if let e = err {
                    promise(.failure(e))
                } else {
                    promise(.success(()))
                    //if we unmatch we want to remove notifications from that user
                    NotificationService.shared.removeNotification(uid)
                        .sink { completion in
                            switch completion {
                            case .finished:
                                print("MatchService_Firebase: finished removing notification from unMatched user")
                            case .failure(let e):
                                print("MatchService_Firebase: Failed to remove notification for UID -> \(uid)")
                                print("MatchService_Firebase-err: \(e)")
                            }
                        } receiveValue: { _ in }
                        .store(in: &self!.cancellables)
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension MatchService_Firebase {
    private func unMatchUser_(with docID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            self!.db.collection("Matches").document(docID).delete() { err in
                if let e = err {
                    promise(.failure(e))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func getMatchDocID(with uid: String) -> AnyPublisher<String, Error> {
        return Future<String, Error> { [weak self] promise in
            self!.db.collection("Matches")
                .whereField("matched", arrayContains: AuthService.shared.currentUser!.uid)
                .whereField("matched", arrayContains: uid)
                .getDocuments { snapshot, err in
                    if let e = err {
                        promise(.failure(e))
                    } else {
                        if let snap = snapshot {
                            let docs = snap.documents
                            
                            var docID: String = ""
                            if docs.count == 0 {
                                promise(.failure(MatchError.emptySnapshot))
                            } else {
                                for doc in docs {
                                    docID = doc.documentID
                                }
                            }
                            promise(.success(docID))
                        } else {
                            promise(.failure(MatchError.emptySnapshot))
                        }
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    enum MatchError: Error {
        case emptySnapshot
    }
}
