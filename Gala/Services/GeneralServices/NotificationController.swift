//
//  NotificationController.swift
//  Gala
//
//  Created by Vaughn on 2022-06-30.
//

import SwiftUI
import Combine
import UserNotifications
import FirebaseMessaging
import FirebaseFirestore

class NotificationController {
    
    let db = Firestore.firestore()
    
    init() {
                
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { [weak self] complete, err in
                    if let _ = err { return }
                    
                    //if there is no error then we need to push the FCM Token to the db
                    
                    Messaging.messaging().token { token, error in
                        if let error = error {
                            print("Error fetching FCM registration token: \(error)")
                        } else if let token = token {
                            print("FCM registration token: \(token)")
                            self?.pushFCM(token)
                        }
                    }
                })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            
            Messaging.messaging().token { [weak self] token, error in
                if let error = error {
                    print("Error fetching FCM registration token: \(error)")
                } else if let token = token {
                    print("FCM registration token: \(token)")
                    self?.pushFCM(token)
                }
            }
        }

        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func pushFCM(_ token: String) {
        
        let data: [String: Any] = [
            "token": token,
            "timestamp" : Date(),
            "name" : UserCoreService.shared.currentUserCore!.userBasic.name,
            "loggedIn" : 1
        ]
        
        db.collection("FCM Tokens").document(AuthService.shared.currentUser!.uid)
            .setData(data) { err in
                if let err = err {
                    print("NotificationController: Failed to push FCM token")
                    print("NotificationController-err: \(err)")
                    return
                } else {
                    print("NotificationController: Successfully pushed FCM Token")
                }
            }
    }
}

class NotificationService {
    
    let db = Firestore.firestore()

    static let shared = NotificationService()
    
    @Published var notifications: [String] = []
    
    private init() {
        
    }
    
    func observeNotifications() {
        db.collection("Notifications").document(AuthService.shared.currentUser!.uid)
            .addSnapshotListener { snapShot, e in
                guard let document = snapShot else { return }
                
                if let doc = document.data() {
                    if let notifications = doc["notifications"] as? [String] {
                        self.notifications = notifications
                        UIApplication.shared.applicationIconBadgeNumber = notifications.count
                    }
                }
            }
    }
    
    func removeNotification(_ uid: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            
            var notifInArray = false
            
            for notif in self!.notifications {
                if notif == uid {
                    notifInArray = true
                }
            }
            
            if notifInArray {
                self?.db.collection("Notifications").document(AuthService.shared.currentUser!.uid)
                    .updateData([
                        "notifications": FieldValue.arrayRemove([uid])
                    ]) { err in
                        if let e = err {
                            promise(.failure(e))
                        } else {
                            promise(.success(()))
                        }
                    }
            } else {
                print("No Notification to delete")
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
}


//i need to test the new system

//1. log out of sav
//2. make sav 'loggedin' in firestore
//3. send sav a message from demi and vaughn
//4. send sav a snap from demi and vaughn

//1. Test open all messages first
//2. test opening all snaps first **WORKS**
//3. test just opening snaps
//4. test just opening messages **WORKS**
