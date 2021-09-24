//
//  VibesService.swift
//  Gala
//
//  Created by Vaughn on 2021-09-21.
//

import Combine
import FirebaseFirestore

protocol VibesServiceProtocol {
    //getPostableVibes
    //  Will get all vibes that the user can post to
    func getPostableVibes(dayOfWeek: String, period: String) -> AnyPublisher<[String], Error>
    
    //getViewAbleVibes
    //  Will get all vibe titles for viewing
    func getViewAbleVibes() -> AnyPublisher<[String], Error>
}

class VibesService: ObservableObject, VibesServiceProtocol {
   
    private let db = Firestore.firestore()
    
    //@Published private(set) var postableVibes: [String] = []
    private var cancellables: [AnyCancellable] = []
    
    static let shared = VibesService()
    private init() { }
    
    //Morning (5am - 11:59am)
    //Afternoon (12:00pm - 4:59pm)
    //Evening (5:00pm - 9:59pm)
    //Night (10:00pm - 4:59am)
    
    func getPostableVibes(dayOfWeek: String, period: String) -> AnyPublisher<[String], Error> {
        return Future<[String], Error> { promise in
            self.db.collection("Vibes").document(dayOfWeek).collection(period).document(period)
                .getDocument { snap, err in
                    if let err = err {
                        print("VibesService: Failed to load vibes for \(dayOfWeek)")
                        promise(.failure(err))
                    } else if let snap = snap {
                        var final: [String] = []
                        if let titles = snap.data()?["titles"] as? [Any] {
                            for i in 0..<titles.count {
                                let title = titles[i] as? String
                                if let title_ = title {
                                    final.append(title_)
                                }
                            }
                        }
                        print("VibesService: titles \(final)")
                        //self?.postableVibes = final
                        promise(.success(final))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    
    
    //We likely will not need this function because if we know the vibe title that will be
    // in the story model, then we can just place them in a bucket
    func getViewAbleVibes() -> AnyPublisher<[String], Error> {
        return Future<[String], Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}
