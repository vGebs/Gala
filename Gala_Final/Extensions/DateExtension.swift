//
//  DateExtension.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Foundation
import Combine

extension Date {
    
    func isAgeValid() -> AnyPublisher<Bool, Never> {
        let today = Date()
        
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        let age = gregorian.components([.year], from: self, to: today, options: [])
        
        if age.year! < 18 {
            return Just(false).eraseToAnyPublisher()
        } else {
            return Just(true).eraseToAnyPublisher()
        }
    }
    
    func ageString() -> String {
        let today = Date()
        
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        let age = gregorian.components([.year], from: self, to: today, options: [])
        
        return String(age.year!)
    }
}
