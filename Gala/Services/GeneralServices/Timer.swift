//
//  Timer.swift
//  Gala
//
//  Created by Vaughn on 2022-07-07.
//

import Foundation
import CoreFoundation

class ParkBenchTimer {
    let startTime: CFAbsoluteTime
    var endTime: CFAbsoluteTime?

    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }

    func stop() -> String {
        endTime = CFAbsoluteTimeGetCurrent()

        return duration!
    }

    var duration: String? {
        if let endTime = endTime {
            let time = endTime - startTime
            let returnString = "Time: \(time)"
            return returnString
        } else {
            return nil
        }
    }
}
