//
//  NotificationController.swift
//  Gala
//
//  Created by Vaughn on 2022-06-30.
//

import SwiftUI
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
