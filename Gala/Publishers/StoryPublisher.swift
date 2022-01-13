//
//  StoryListener.swift
//  Gala
//
//  Created by Vaughn on 2022-01-13.
//

import Combine
import FirebaseFirestore

extension Publishers {
    struct StoryPublisher: Publisher {
        typealias Output = Date?
        typealias Failure = Never
        
        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Date? == S.Input {
            
            let storySubscription = StorySubscription(subscriber: subscriber)
            subscriber.receive(subscription: storySubscription)
        }
    }
    
    class StorySubscription<S: Subscriber>: Subscription where S.Input == Date?, S.Failure == Never {
        
        private let db = Firestore.firestore()
        
        private var subscriber: S?
        private var handler: ListenerRegistration?
        
        init(subscriber: S){
            self.subscriber = subscriber
            self.handler = db.collection("cities").document("SF")
                .addSnapshotListener { documentSnapshot, error in
                  guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                  }
                  guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                  }
                  print("Current data: \(data)")
                }
        }
        
        func request(_ demand: Subscribers.Demand) { }
        
        func cancel() {
            subscriber = nil
            handler = nil
        }
    }
}
