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
    
    func formatDate() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        return format.string(from: self)
    }
    
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

extension Date {
    init(_ dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        let date = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:date)
    }
}

extension Date {
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}
