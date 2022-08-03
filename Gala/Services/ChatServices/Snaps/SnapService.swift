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
    func sendSnap(to: String, asset: Data, isImage: Bool, caption: String?, height: CGFloat?) -> AnyPublisher<Void, Error>
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
                    let isImage = data["isImage"] as? Bool
                    
                    let snapID_timestamp_ = data["snapID_timestamp"] as? Timestamp
                    
                    if let snapID_timestamp = snapID_timestamp_?.dateValue() {
                        if let o = opened {
                            if let isImage = isImage {
                                let newSnap = Snap(fromID: fromID, toID: toID, snapID_timestamp: snapID_timestamp, openedDate: o.dateValue(), isImage: isImage, docID: docID)
                                final.append(newSnap)
                            }
                        } else {
                            if let isImage = isImage {
                                let newSnap = Snap(fromID: fromID, toID: toID, snapID_timestamp: snapID_timestamp, openedDate: nil, isImage: isImage, docID: docID)
                                final.append(newSnap)

                            }
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
                    let isImage = data["isImage"] as? Bool
                    let snapID_timestamp_ = data["snapID_timestamp"] as? Timestamp

                    if let snapID_timestamp = snapID_timestamp_?.dateValue() {
                        if let o = openedDate{
                            let newSnap = Snap(fromID: fromID, toID: toID, snapID_timestamp: snapID_timestamp, openedDate: o.dateValue(), isImage: isImage!, docID: docID)
                            final.append(newSnap)
                        } else {
                            let newSnap = Snap(fromID: fromID, toID: toID, snapID_timestamp: snapID_timestamp, openedDate: nil, isImage: isImage!, docID: docID)
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
    
    func sendSnap(to: String, asset: Data, isImage: Bool, caption: String? = nil, height: CGFloat? = nil) -> AnyPublisher<Void, Error>{
        
        let date = Date()
        return Future<Void, Error> { [weak self] promise in
            Publishers.Zip(
                self!.pushMeta(to, date, isImage, caption: caption, height: height),
                self!.pushAsset(to, asset, date, isImage: isImage)
            )
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
    
    func fetchSnapAsset(snapID: Date, isImage: Bool) -> AnyPublisher<(Data?, URL?), Error> {
        let storageRef = storage.reference()
        let snapFolderRef = storageRef.child("Snaps")
        let toImgRef = snapFolderRef.child(AuthService.shared.currentUser!.uid)
        let imgFileRef: StorageReference
        
        if isImage {
            imgFileRef = toImgRef.child("\(snapID)")
        } else {
            imgFileRef = toImgRef.child("\(snapID).mov")
        }
        
        return Future<(Data?, URL?), Error> { promise in
            if isImage {
                imgFileRef.getData(maxSize: 30 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("SnapService: Non lethal fetching error: \(error.localizedDescription)")
                        promise(.success((nil, nil)))
                    }
                    
                    if let data = data {
                        promise(.success((data, nil)))
                    } else {
                        promise(.success((nil, nil)))
                    }
                }
            } else {
               
                let saveToUrl = getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).mov")
                
                imgFileRef.write(toFile: saveToUrl) { url, error in
                    if let e = error {
                        promise(.failure(e))
                    } else {
                        if let url = url {
                            print("SnapService: Successfully wrote video to url: \(url)")
                            promise(.success((nil, url)))
                        } else {
                            promise(.success((nil, nil)))
                        }
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func openSnap(snap: Snap) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            Publishers.Zip(
                self!.openSnap_(snap: snap),
                self!.deleteAsset(snap: snap)
            )
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("SnapService: Failed to open snap and delete asset")
                        print("SnapService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("SnapService: Finished opening snap meta and deleting asset")
                        promise(.success(()))
                    }
                } receiveValue: { _, _ in }
                .store(in: &self!.cancellables)
        }.eraseToAnyPublisher()
    }
    
    func deleteSnap(snap: Snap) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            Publishers.Zip(
                self!.deleteMeta(snap: snap),
                self!.deleteAsset(snap: snap)
            )
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("SnapService: Failed to delete snap meta and asset")
                        print("SnapService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("SnapService: Finished deleting snap meta and asset")
                        promise(.success(()))
                    }
                } receiveValue: { _, _ in }
                .store(in: &self!.cancellables)
            
        }.eraseToAnyPublisher()
    }
    
    func deleteMeta(snap: Snap) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            self!.db.collection("Snaps").document(snap.docID).delete() { err in
                if let e = err {
                    print("SnapService: Failed to delete snap meta")
                    print("SnapService-err: \(e)")
                    promise(.failure(e))
                } else {
                    print("SnapService: Successfully deleted snap meta")
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension SnapService {
    
    private func openSnap_(snap: Snap) -> AnyPublisher<Void, Error> {
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
    
    private func pushMeta(_ to: String, _ date: Date, _ isImage: Bool, caption: String? = nil, height: CGFloat? = nil) -> AnyPublisher<Void, Error> {
        
        if let caption = caption, let height = height{
            if caption.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                return pushMetaWithCaption(to, date, isImage, caption: caption, height: height)
            } else {
                return pushMetaWithoutCaption(to, date, isImage)
            }
        } else {
            return pushMetaWithoutCaption(to, date, isImage)
        }
    }
    
    private func pushAsset(_ to: String, _ asset: Data, _ date: Date, isImage: Bool) -> AnyPublisher<Void, Error> {
        let storageRef = storage.reference()
        let snapsFolderName = "Snaps"
        let snapFolderRef = storageRef.child(snapsFolderName)
        let toImgRef = snapFolderRef.child(to)
        
        let imgFileRef: StorageReference
        
        if isImage {
            imgFileRef = toImgRef.child("\(date)")
        } else {
            imgFileRef = toImgRef.child("\(date).mov")
        }
        
        return Future<Void, Error> { promise in
            let _ = imgFileRef.putData(asset, metadata: nil) { (metaData, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    return promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func pushMetaWithCaption(_ to: String, _ date: Date, _ isImage: Bool, caption: String, height: CGFloat) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            self!.db.collection("Snaps")
                .addDocument(data: [
                    "toID": to,
                    "fromID": AuthService.shared.currentUser!.uid,
                    "fromName": UserCoreService.shared.currentUserCore!.userBasic.name,
                    "isImage": isImage,
                    "caption": caption,
                    "height": height,
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
    
    private func pushMetaWithoutCaption(_ to: String, _ date: Date, _ isImage: Bool) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            self!.db.collection("Snaps")
                .addDocument(data: [
                    "toID": to,
                    "fromID": AuthService.shared.currentUser!.uid,
                    "fromName": UserCoreService.shared.currentUserCore!.userBasic.name,
                    "isImage": isImage,
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
    
    private func deleteAsset(snap: Snap) -> AnyPublisher<Void, Error> {
        let storageRef = storage.reference()
        let snapsFolderName = "Snaps"
        let snapFolderRef = storageRef.child(snapsFolderName)
        
        //we only want to delete the snaps that are sent to us
        let toImgRef = snapFolderRef.child(AuthService.shared.currentUser!.uid)
        let imgFileRef: StorageReference
        
        if snap.isImage {
            imgFileRef = toImgRef.child("\(snap.snapID_timestamp)")
        } else {
            imgFileRef = toImgRef.child("\(snap.snapID_timestamp).mov")
            
            if let url = snap.vidURL {
                deleteLocalFile(at: url)
            }
        }
        
        return Future<Void, Error> { promise in
            imgFileRef.delete { err in
                if let e = err {
                    print("SnapService: Failed to delete snap asset")
                    print("SnapService-err: \(e)")
                    promise(.failure(e))
                } else {
                    print("SnapServie: Successfully deleted snap asset")
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}
