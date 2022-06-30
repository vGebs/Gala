//
//  Gala_FinalApp.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

//Swift Package Manager Tutorial
///https://www.raywenderlich.com/7242045-swift-package-manager-for-ios#toc-anchor-011

//Xcode Version Control Tutorial:
///https://www.raywenderlich.com/675-how-to-use-git-source-control-with-xcode-9

var screenWidth = UIScreen.main.bounds.width
var screenHeight = UIScreen.main.bounds.height
var compressionQuality: CGFloat = 0.2

import SwiftUI
import Firebase
import Combine
import FirebaseMessaging
import UserNotifications

//MARK: - To do (BIG TASKS, not required, but needed for release):

    //4. Add text to images like snap
        //Add some filters (check github for any filter packages)

    //5. Delete all chats after 24 hours.
        //Ability to save singular message for longer than 24 hours
        //Ability to save whole chat for ____ days...?

    //6. Secure database rules & make sure our firebase key is not in Github
        ///Link: https://firebase.google.com/docs/firestore/solutions/role-based-access

//MARK: - To do (Big task, not needed for launch)

    //1. plug app with google analytics
        ///link: https://firebase.google.com/docs/analytics/get-started?platform=ios

    //2. plug app with firebase predictions:
        ///link: https://firebase.google.com/docs/predictions

    //3. Filter out nude images:
        ///link: https://firebase.google.com/docs/ml/train-image-labeler

var loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
var email = UserDefaults.standard.string(forKey: "email")
var password = UserDefaults.standard.string(forKey: "password")

@main
struct GalaApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            LaunchView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self

        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {

        let deviceToken:[String: String] = ["token": fcmToken ?? ""]
        print("Device token: ", deviceToken) // This token can be used for testing notifications on FCM
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        print(userInfo)

        // Change this to your preferred presentation option
        completionHandler([[.banner, .badge, .sound]])
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID from userNotificationCenter didReceive: \(messageID)")
        }

        print(userInfo)

        completionHandler()
    }
}
