//
//  TestView.swift
//  Gala
//
//  Created by Vaughn on 2021-08-25.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        SliderView(slider: CustomSlider(start: 18, end: 99, doubleKnob: true))
        SliderView(slider: CustomSlider(start: 1, end: 250, doubleKnob: false))
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
