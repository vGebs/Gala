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
                    "snapID_timestamp": date,
                    "opened": false
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
}
