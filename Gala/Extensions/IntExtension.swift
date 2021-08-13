//
//  IntExtension.swift
//  Gala
//
//  Created by Vaughn on 2021-07-29.
//

import Foundation

extension Int {
    func getDateForAge() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        
        let ageMinDate = Calendar.current.date(
          byAdding: .year,
          value: -self,
          to: Date()
        )
        return format.string(from: ageMinDate!)
    }
}
