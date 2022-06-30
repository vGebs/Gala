//
//  NotificationController.swift
//  Gala
//
//  Created by Vaughn on 2022-06-30.
//

import SwiftUI
import Foundation
import Combine
import UserNotifications

class NotificationController {
    init() {
                
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()
    }
}
