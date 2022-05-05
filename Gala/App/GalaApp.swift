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

class AppDelegate: NSObject, UIApplicationDelegate{
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        print("AppDelegate: Firebase configured")
        return true
    }
}
