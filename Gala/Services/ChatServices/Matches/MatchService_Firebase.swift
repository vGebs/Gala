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
    
    func observeMatches(completion: @escaping ([Match], DocumentChangeType) -> Void) { //fromDate: Timestamp,
        db.collection("Matches")
            .whereField("matched", arrayContains: String(AuthService.shared.currentUser!.uid))
            .addSnapshotListener { documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("MatchService: Error fetching document: \(error!)")
                    return
                }
                
                var finalMatches: [Match] = []
                var documentChangeType: DocumentChangeType = .added
                
                documentSnapshot?.documentChanges.forEach({ change in
                    let data = change.document.data()
                    let timestamp = data["time"] as? Timestamp
                    
                    if change.type == .added {
                        if let matchDate = timestamp?.dateValue(){
                            if let uids = data["matched"] as? [String] {
                                for uid in uids {
                                    if uid != AuthService.shared.currentUser!.uid {
                                        let match = Match(matchedUID: uid, timeMatched: matchDate, docID: change.document.documentID)
                                        finalMatches.append(match)
                                        print("MatchService: Added new match: \(uid)")
                                    }
                                }
                            }
                        }
                    }
                    
                    if change.type == .removed {
                        if let matchDate = timestamp?.dateValue(){
                            if let uids = data["matched"] as? [String] {
                                for uid in uids {
                                    if uid != AuthService.shared.currentUser!.uid {
                                        let match = Match(matchedUID: uid, timeMatched: matchDate, docID: change.document.documentID)
                                        finalMatches.append(match)
                                        print("MatchService: removed match: \(uid)")
                                    }
                                }
                            }
                        }
                        
                        documentChangeType = .removed
                    }
                    
                    if change.type == .modified {
                        if let matchDate = timestamp?.dateValue(){
                            if let uids = data["matched"] as? [String] {
                                for uid in uids {
                                    if uid != AuthService.shared.currentUser!.uid {
                                        let match = Match(matchedUID: uid, timeMatched: matchDate, docID: change.document.documentID)
                                        finalMatches.append(match)
                                        print("MatchService: Added new match: \(uid)")
                                    }
                                }
                            }
                        }
                        documentChangeType = .modified
                    }
                })
                completion(finalMatches, documentChangeType)
            }
    }
    
    func unMatchUser(with docID: String) -> AnyPublisher<Void, Error> {
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
