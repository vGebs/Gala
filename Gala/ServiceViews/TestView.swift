//
//  TestView.swift
//  Gala
//
//  Created by Vaughn on 2021-08-18.
//

import SwiftUI

//Link for tutorial: https://stackoverflow.com/questions/62587261/swiftui-2-handle-range-slider

struct TestView: View {
    @ObservedObject var slider = CustomSlider(start: 18, end: 99)

    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(.all)
            SliderView(slider: slider)
//            HStack {
//                //Spacer()
//                ZStack{
//                    RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 1)
//                        .foregroundColor(.accent)
//
//                    Text("\(Int(min(slider.lowHandle.currentValue, slider.highHandle.currentValue)))y")
//                        .font(.system(size: 15, weight: .regular, design: .rounded))
//                        .foregroundColor(.primary)
//                }
//                .frame(width: screenWidth * 0.09, height: screenWidth * 0.07)
//
//                Spacer()
//                SliderView(slider: slider)
//                Spacer()
//
//                ZStack{
//                    RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 1)
//                        .foregroundColor(.accent)
//
//                    Text("\(Int(max(slider.highHandle.currentValue, slider.lowHandle.currentValue)))y")
//                        .font(.system(size: 15, weight: .regular, design: .rounded))
//                        .foregroundColor(.primary)
//                }
//                .frame(width: screenWidth * 0.09, height: screenWidth * 0.07)
//
//                //Spacer()
//            }
//            .frame(width: screenWidth * 0.9)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
