//
//  ColorExtension.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
}

extension Color {
    static let neuBackground = Color(hex: "f0f0f3")
    static let dropShadow = Color(hex: "aeaec0").opacity(0.4)
    static let dropLight = Color(hex: "ffffff")
    
    static let primary = Color(hex: "BA274A")//ColorScheme 1: Color(hex: "F40B73")
    static let accent = Color(hex: "373F51")//ColorScheme 1: Color(hex: "F4170B")
    static let buttonPrimary = Color(hex: "1098F7")//ColorScheme 1: Color(hex: "F40BE8")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
}
