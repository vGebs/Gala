//
//  TestDistance.swift
//  Gala
//
//  Created by Vaughn on 2021-08-26.
//

import SwiftUI
import MapKit
import CoreLocation

struct TestDistance: View {
    
    var body: some View {
        Text("\(dummy())km to work")
    }
}

struct TestDistance_Previews: PreviewProvider {
    static var previews: some View {
        TestDistance()
    }
}

func dummy() -> Int {
    let lat = 50.449874070607855
    let lon = -104.61629726800464
    let myLoc = CLLocation(latitude: lat, longitude: lon)
    let to = CLLocation(latitude: 50.48264987, longitude: -104.70606885)
    
    let distance = myLoc.distance(from: to) / 1000
    return Int(distance)
}
