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
    func getPostableVibes() -> AnyPublisher<[String], Error>
    
    //getViewAbleVibes
    //  Will get all vibe titles for viewing
    func getViewAbleVibes() -> AnyPublisher<[String], Error>
}

class VibesService: ObservableObject, VibesServiceProtocol {
   
    private let db = Firestore.firestore()
    
    static let shared = VibesService()
    private init() {}
    
    //Morning (5am - 11:59am)
    //Afternoon (12:00pm - 4:59pm)
    //Evening (5:00pm - 9:59pm)
    //Night (10:00pm - 4:59am)
    
    func getPostableVibes() -> AnyPublisher<[String], Error> {
        return Future<[String], Error> { promise in
            let day = Date().dayOfWeek()!
            let period = self.getTimeOfDay()
            self.db.collection("Vibes").document(day).collection(period).document(period)
                .getDocument { snap, err in
                    if let err = err {
                        print("VibesService: Failed to load vibes for \(day)")
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
                        promise(.success(final))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    private func getTimeOfDay() -> String {
        let date = Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)

        let time = "\(hour)" + ":" + "\(minute)" + ":" + "\(second)"
        
        if time >= "5:00:00" && time < "12:00:00" {
            return "Morning"
        } else if time >= "12:00:00" && time < "17:00:00" {
            return "Afternoon"
        } else if time >= "17:00:00" && time < "22:00:00" {
            return "Evening"
        } else if time >= "22:00:00"{
            return "Night"
        } else if time <= "5:00:00" {
            return "Night"
        }
        return ""
    }
    
    //We likely will not need this function because if we know the vibe title that will be
    // in the story model, then we can just place them in a bucket
    func getViewAbleVibes() -> AnyPublisher<[String], Error> {
        return Future<[String], Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}
