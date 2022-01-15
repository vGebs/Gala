//
//  CurrentUserSexualityAndGender.swift
//  Gala
//
//  Created by Vaughn on 2022-01-14.
//

import Foundation

enum CurrentUserSexualityAndGender {
    case straightMale
    case gayMale
    case biMale
    
    case straightFemale
    case gayFemale
    case biFemale
}

func getCurrentUserSexualityAndGender() -> CurrentUserSexualityAndGender {
    print("RecentlyJoinedUserService: \(String(describing: UserCoreService.shared.currentUserCore?.sexuality))")
    if UserCoreService.shared.currentUserCore?.gender == "male" {
        if UserCoreService.shared.currentUserCore?.sexuality == "straight" {
            print("RecentlyJoinedUserService: Straight male")
            return .straightMale
        
        } else if UserCoreService.shared.currentUserCore?.sexuality == "gay"{
            print("RecentlyJoinedUserService: Gay male")
            return .gayMale
            
        } else {
            print("RecentlyJoinedUserService: Bisexual male")
            return .biMale
        }
    } else {
        if UserCoreService.shared.currentUserCore?.sexuality == "straight" {
            print("RecentlyJoinedUserService: Straight Female")
            return .straightFemale
            
        } else if UserCoreService.shared.currentUserCore?.sexuality == "gay"{
            print("RecentlyJoinedUserService: Gay Female")
            return .gayFemale
            
        } else {
            print("RecentlyJoinedUserService: Bisexual Female")
            return .biFemale
        }
    }
}
