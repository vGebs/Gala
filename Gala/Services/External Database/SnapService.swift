//
//  SnapService.swift
//  Gala
//
//  Created by Vaughn on 2022-02-17.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore
import FirebaseStorage

protocol SnapServiceProtocol {
    func sendSnap(to: String, img: UIImage) -> AnyPublisher<Void, Error>
}

class SnapService: SnapServiceProtocol {
    
    static let shared = SnapService()
    
    private var cancellables: [AnyCancellable] = []
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}
    
    func observeSnapsToMe(completion: @escaping ([Snap], DocumentChangeType) -> Void) {
        db.collection("Snaps")
            .whereField("toID", isEqualTo: String(AuthService.shared.currentUser!.uid))
            .order(by: "snapID_timestamp")
            .addSnapshotListener { documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("Error fetching snaps to me: \(error!)")
                    return
                }
                
                var final: [Snap] = []
                var docChange: DocumentChangeType = .added
                
                documentSnapshot?.documentChanges.forEach({ change in
                    let data = change.document.data()
                    let docID = change.document.documentID
                    let toID = data["toID"] as? String ?? ""
                    let fromID = data["fromID"] as? String ?? ""
                    let opened = data["openedDate"] as? Timestamp
                    let snapID_timestamp_ = data["snapID_timestamp"] as? Timestamp
                    
                    if let snapID_timestamp = snapID_timestamp_?.dateValue() {
                        if let o = opened {
                            let newSnap = Snap(fromID: fromID, toID: toID, snapID_timestamp: snapID_timestamp, openedDate: o.dateValue(), img: nil, docID: docID)
                            final.append(newSnap)
                        } else {
                            let newSnap = Snap(fromID: fromID, toID: toID, snapID_timestamp: snapID_timestamp, openedDate: nil, img: nil, docID: docID)
                            final.append(newSnap)
                        }
                    }
                    
                    if change.type == .modified {
                        docChange = .modified
                        
                    } else if change.type == .removed {
                        docChange = .removed
                    }
                })
                
                completion(final, docChange)
            }
    }
    
    func observerSnapsfromMe(completion: @escaping ([Snap], DocumentChangeType) -> Void) {
        db.collection("Snaps")
            .whereField("fromID", isEqualTo: String(AuthService.shared.currentUser!.uid))
            .order(by: "snapID_timestamp")
            .addSnapshotListener { documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                var final: [Snap] = []
                var documentChangeType: DocumentChangeType = .added
                
                documentSnapshot?.documentChanges.forEach({ change in
                    let data = change.document.data()
                    let docID = change.document.documentID
                    
                    let toID = data["toID"] as? String ?? ""
                    let fromID = data["fromID"] as? String ?? ""
                    let openedDate = data["openedDate"] as? Timestamp
                    let snapID_timestamp_ = data["snapID_timestamp"] as? Timestamp

                    if let snapID_timestamp = snapID_timestamp_?.dateValue() {
                        if let o = openedDate{
                            let newSnap = Snap(fromID: fromID, toID: toID, snapID_timestamp: snapID_timestamp, openedDate: o.dateValue(), img: nil, docID: docID)
                            final.append(newSnap)
                        } else {
                            let newSnap = Snap(fromID: fromID, toID: toID, snapID_timestamp: snapID_timestamp, openedDate: nil, img: nil, docID: docID)
                            final.append(newSnap)
                        }
                    }
                    
                    if change.type == .modified {
                        documentChangeType = .modified
                        
                    } else if change.type == .removed {
                        documentChangeType = .removed
                    }
                })
                
                completion(final, documentChangeType)
            }
    }
    
    func sendSnap(to: String, img: UIImage) -> AnyPublisher<Void, Error>{
        let date = Date()
        return Future<Void, Error> { [weak self] promise in
            Publishers.Zip(self!.pushMeta(to, date), self!.pushImage(to, img, date))
                .sink { completion in
                    switch completion{
                    case .failure(let e):
                        print("SnapService: Failed to send snap")
                        print("SnapService-err: \(e)")
                    case .finished:
                        print("SnapService: Successfully sent snap")
                    }
                } receiveValue: { _, _ in }
                .store(in: &self!.cancellables)
        }.eraseToAnyPublisher()
    }
    
    func pushMeta(_ to: String, _ date: Date) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            self!.db.collection("Snaps")
                .addDocument(data: [
                    "toID": to,
                    "fromID": AuthService.shared.currentUser!.uid,
                    "snapID_timestamp": date
                ]){ err in
                    if let err = err {
                        print("SnapService: Failed to send snap to id: \(to)")
                        print("SnapService-Error: \(err.localizedDescription)")
                        promise(.failure(err))
                    } else {
                        print("SnapService: Successfully send snap to user with id: \(to)")
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    func pushImage(_ to: String, _ img: UIImage, _ date: Date) -> AnyPublisher<Void, Error> {
        let data = img.jpegData(compressionQuality: compressionQuality)!
        let storageRef = storage.reference()
        let snapsFolderName = "Snaps"
        let snapFolderRef = storageRef.child(snapsFolderName)
        let toImgRef = snapFolderRef.child(to)
        let imgFileRef = toImgRef.child("\(date).jpeg")
        
        return Future<Void, Error> { promise in
            let _ = imgFileRef.putData(data, metadata: nil) { (metaData, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    return promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchSnap(snapID: Date) -> AnyPublisher<UIImage?, Error> {
        let storageRef = storage.reference()
        let snapFolderRef = storageRef.child("Snaps")
        let toImgRef = snapFolderRef.child(AuthService.shared.currentUser!.uid)
        let imgFileRef = toImgRef.child("\(snapID).jpeg")
        
        return Future<UIImage?, Error> { promise in
            imgFileRef.getData(maxSize: 30 * 1024 * 1024) { data, error in
                if let error = error {
                    print("SnapService: Non lethal fetching error: \(error.localizedDescription)")
                    promise(.failure(error))
                }
                
                if let data = data {
                    let img = UIImage(data: data)
                    promise(.success(img))
                } else {
                    promise(.success(nil))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func openSnap(snap: Snap) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            self?.db.collection("Snaps").document(snap.docID)
                .updateData(["openedDate": Date()]) { err in
                    if let e = err {
                        print("ChatService: Failed to update document")
                        print("ChatService-err: \(e)")
                        promise(.failure(e))
                    } else {
                        print("ChatService: Successfully updated document")
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    func deleteSnap(snap: Snap) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
    
    func deletMeta(snap: Snap) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
    
    func deleteAsset(snap: Snap) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}
