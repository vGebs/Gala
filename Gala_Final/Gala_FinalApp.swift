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
import SwiftUICam
import Firebase
import Combine

//MARK: - Next steps
    
//MARK: - DONE
    ///Right now:
        ///Read textbook on concurrency
        ///Resequence the app such that the login and data pull is smooth
    ///Problem:
        ///Compressing, pushing and pulling images/video takes too long

    ///Solutions:
        ///1. Do not compress images when selecting from camera roll
            ///Instead compress before pushing to dataBase
        ///2. After user creates and account and fills in profile
            ///Load all needed data and then allow user to enter contentView

    //Problem:
        //Retain cycles are causing the apps memory to leak
        
    //Solution:
        //Put signIn/Signup in the ContentView and make the ContentView
            //control the state of authentication & profile creation.
            //ZStack w the signin on top. Animation to dismiss and deinit
        //SwiftUI is a function of state. The login and signup view
            //should depend on the state of the ContentView.
        //ContentView is independent of the Login forms. To see the
            //ContentView, one must pass authentication and then the
                //ContentView will let the user in by dismissing the signin forms.
//MARK: - DONE

    //Problem:
        //Core data models are not being rendered.

    //Solution:
        //Make a test file and debug from there.
        //Once core data works, allow user to enter app once core data is done being saved.

    //Problem:
        //Images coming back from FB are not in order

    //Soultions:
        //Create a container class that can hold any type of object
        //Add an insert function that inserts the images in order based on their ID

//MARK: - To Do (Required Functionality)

    //1. Save profile images to firebase storage and store with userID
        //Pull images if core data returns nil

    //2. Get user location.
        ///Link: https://mobileinvader.com/corelocation-in-swiftui-mvvm-unit-tests/
        //Push location to database every 7 minutes while in app
        //Push location everytime app is relaunched

    //3. Be able to post images

    //4. After restyling explore view
        //Pull users that have posted based on location
        //Allow user to select the sorting based on their query (age range, nearMe, global, most compatible?)
        //GEO query -> Link: https://firebase.google.com/docs/firestore/solutions/geoqueries

    //5. Allow for users to like one another
        //When two users both like each other, add to matches
        //add a listener for new matches

    //6. After restyling chats view
        //Allow user to sort chats, based on age, location, & most recent

    //7. Create a messanger view with chat bubbles
        //Make sure most recent messages are placed last
    
    //8. Be able to send messages
        //add a listener for new messages

//MARK: - To do (BIG TASKS, not required, but needed for release):

    //1. After user signs up and creates an account,
        //a. User access to core data. email as UUID.
            //Abstract core data such that it can only be accessed from the viewModel

        //b. Find out how to save images to core data.
            //Link: https://betterprogramming.pub/how-to-save-an-image-to-core-data-with-swift-a1105ae2cf04

        //c. Get Users location and push it to database every 15 mins
            //Get location -> Link: https://mobileinvader.com/corelocation-in-swiftui-mvvm-unit-tests/
            //Scheduled database push -> Link:

    //2. Implement Pages
        //Going to have to fix cam. Possible area of issue is draggable camera button

    //3. Make an appState object. When the user is logged out, deinitialize all viewModels.
        //Retain cycle and memory leak: https://doordash.engineering/2019/05/22/ios-memory-leaks-and-retain-cycle-detection-using-xcodes-memory-graph-debugger/

        //How to fix:
            //Create a ZStack and put the login/Signup, then behind that create profile, then behind that the main pagerView
            //Instead of having a naviagtion link that depends on the value of another class, make the signup appear on the top
            //SwiftUI is a function of state. The login and signup view should depend on the state of the ContentView

    //4. Add text to images like snap
        //Add some filters (check github for any filter packages)

    //5. Delete all chats after 24 hours.
        //Ability to save singular message for longer than 24 hours
        //Ability to save whole chat for ____ days...?

    //6. Secure database rules
        ///Link: https://firebase.google.com/docs/firestore/solutions/role-based-access

    //7. plug app with google analytics
        ///link: https://firebase.google.com/docs/analytics/get-started?platform=ios

//MARK: - To do (Big task, not needed for launch)

    //1. plug app with firebase predictions:
        ///link: https://firebase.google.com/docs/predictions

    //2. Filter out nude images:
        ///link: https://firebase.google.com/docs/ml/train-image-labeler
    
    //3. Add maps feature

//MARK: - To do (smaller tasks)
    
    //1. switch to dark mode (ensure that it works for all views [do after making each view])
    //2. remake the explore view to be complient with the profile view & viewModel.
    //3. remake the chats view to be complient with the profile view & viewModel.
    //4. style the cameraView
    //6. screen freezes when user tries to sign up with existing email
    //7. remake the check image stats button that is on every page (top left)

var loggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
var email = UserDefaults.standard.string(forKey: "email")
var password = UserDefaults.standard.string(forKey: "password")

@main
struct GalaAppp: App {
        
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("isDarkMode") var isDarkMode = true

    var body: some Scene {
        WindowGroup {
            LaunchView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate{
    
    var userService = UserService.shared
    private var cancellables: [AnyCancellable] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("setting up firebase")
        FirebaseApp.configure()
        
//        if loggedIn && (userService.currentUser == nil){
//            if let email = email, let password = password {
//                userService.signInWithEmail(email: email, password: password)
//                    .sink { completion in
//                        switch completion {
//                        case .failure(let error):
//                            print(error.localizedDescription)
//                            fatalError()
//                        case .finished:
//                            print("Logged in")
//                            return true
//                        }
//                    } receiveValue: { _ in }
//                    .store(in: &cancellables)
//            }
//        }
        
        return true
    }
}

