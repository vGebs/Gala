//
//  TestWeekday.swift
//  Gala
//
//  Created by Vaughn on 2021-09-21.
//

import SwiftUI
import Foundation

struct TestWeekday: View {
    var body: some View {
        Text("\(Date().dayOfWeek()!)")
    }
}

struct TestWeekday_Previews: PreviewProvider {
    static var previews: some View {
        TestWeekday()
    }
}
