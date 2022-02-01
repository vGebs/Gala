//
//  VibeImageService.swift
//  Gala
//
//  Created by Vaughn on 2022-02-01.
//

import Combine
import SwiftUI
import FirebaseStorage

class VibeImageService {
    
    private let storage = Storage.storage()
    
    static let shared = VibeImageService()
    private var cancellables: [AnyCancellable] = []
    
    func fetchImage(name: Int) -> AnyPublisher<UIImage?, Error> {
        let storageRef = storage.reference()
        let vibesRef = storageRef.child("Vibes")
        let imgFileRef = vibesRef.child("\(name).jpeg")
        
        return Future<UIImage?, Error> { promise in
            imgFileRef.getData(maxSize: 30 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Non lethal fetching error (ImageService): \(error.localizedDescription)")
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
}
