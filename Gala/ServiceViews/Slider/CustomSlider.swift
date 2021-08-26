//
//  TwoKnobSlider.swift
//  Gala
//
//  Created by Vaughn on 2021-08-25.
//

import Combine
import SwiftUI

class CustomSlider: ObservableObject {
    
    //Slider Size
    final let width: CGFloat = screenWidth * 0.65
    final let lineWidth: CGFloat = 3
    
    //Slider value range from valueStart to valueEnd
    final let valueStart: Double
    final let valueEnd: Double
    
    //Slider Handle
    @Published var highHandle: SliderHandle
    @Published var lowHandle: SliderHandle?
    
    //Handle start percentage (also for starting point)
    @SliderValue var highHandleStartPercentage = 1.0
    @SliderValue var lowHandleStartPercentage = 0.0
    
    final var anyCancellableHigh: AnyCancellable?
    final var anyCancellableLow: AnyCancellable?
    
    @Published var doubleKnob: Bool
    
    init(start: Double, end: Double, doubleKnob: Bool) {
        valueStart = start
        valueEnd = end
        self.doubleKnob = doubleKnob
        
        if !doubleKnob {
            _highHandleStartPercentage = SliderValue(wrappedValue: 0.5)
        }
        
        highHandle = SliderHandle(sliderWidth: width,
                                  sliderHeight: lineWidth,
                                  sliderValueStart: valueStart,
                                  sliderValueEnd: valueEnd,
                                  startPercentage: _highHandleStartPercentage
        )
        
        if doubleKnob {
            lowHandle = SliderHandle(sliderWidth: width,
                                     sliderHeight: lineWidth,
                                     sliderValueStart: valueStart,
                                     sliderValueEnd: valueEnd,
                                     startPercentage: _lowHandleStartPercentage
            )
        }
        
        anyCancellableHigh = highHandle.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
        
        if doubleKnob {
            anyCancellableLow = lowHandle?.objectWillChange.sink { _ in
                self.objectWillChange.send()
            }
        }
    }
    
    //Percentages between high and low handle
//    var percentagesBetween: String {
//        return String(format: "%.2f", highHandle.currentPercentage.wrappedValue - lowHandle.currentPercentage.wrappedValue)
//    }
    
    //Value between high and low handle
//    var valueBetween: String {
//        return String(format: "%.2f", highHandle.currentValue - lowHandle.currentValue)
//    }
}

class TwoKnobSlider1: ObservableObject {
    
    //Slider Size
    final let width: CGFloat = screenWidth * 0.65
    final let lineWidth: CGFloat = 3
    
    //Slider value range from valueStart to valueEnd
    final let valueStart: Double
    final let valueEnd: Double
    
    //Slider Handle
    @Published var highHandle: SliderHandle
    @Published var lowHandle: SliderHandle
    
    //Handle start percentage (also for starting point)
    @SliderValue var highHandleStartPercentage = 1.0
    @SliderValue var lowHandleStartPercentage = 0.0
    
    final var anyCancellableHigh: AnyCancellable?
    final var anyCancellableLow: AnyCancellable?
    
    init(start: Double, end: Double) {
        valueStart = start
        valueEnd = end
        
        highHandle = SliderHandle(sliderWidth: width,
                                  sliderHeight: lineWidth,
                                  sliderValueStart: valueStart,
                                  sliderValueEnd: valueEnd,
                                  startPercentage: _highHandleStartPercentage
        )
        
        lowHandle = SliderHandle(sliderWidth: width,
                                 sliderHeight: lineWidth,
                                 sliderValueStart: valueStart,
                                 sliderValueEnd: valueEnd,
                                 startPercentage: _lowHandleStartPercentage
        )
        
        anyCancellableHigh = highHandle.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
        anyCancellableLow = lowHandle.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
    }
    
    //Percentages between high and low handle
    var percentagesBetween: String {
        return String(format: "%.2f", highHandle.currentPercentage.wrappedValue - lowHandle.currentPercentage.wrappedValue)
    }
    
    //Value between high and low handle
    var valueBetween: String {
        return String(format: "%.2f", highHandle.currentValue - lowHandle.currentValue)
    }
}
