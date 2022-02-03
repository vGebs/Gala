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
    
    func fetchImage(name: String) -> AnyPublisher<VibeCoverImage?, Error> {
        let storageRef = storage.reference()
        let vibesRef = storageRef.child("Vibes")
        let imgFileRef = vibesRef.child("\(name).jpeg")
        
        return Future<VibeCoverImage?, Error> { promise in
            imgFileRef.getData(maxSize: 30 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Non lethal fetching error (ImageService): \(error.localizedDescription)")
                }
                
                if let data = data {
                    let img = UIImage(data: data)
                    if let img = img {
                        let vibe = VibeCoverImage(image: img, title: name)
                        promise(.success(vibe))
                    }
                } else {
                    promise(.success(nil))
                }
            }
        }.eraseToAnyPublisher()
    }
}
