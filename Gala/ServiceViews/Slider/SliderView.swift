//
//  SliderView.swift
//  Gala
//
//  Created by Vaughn on 2021-08-18.
//

import SwiftUI

struct SliderView: View {
    @ObservedObject var slider: CustomSlider
    
    var body: some View {
        HStack{
            ZStack{
                RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 1)
                    .foregroundColor(.accent)
                if slider.doubleKnob {
                    Text("\(Int(min(slider.lowHandle!.currentValue, slider.highHandle.currentValue)))y")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                } else {
                    Text("\( Int(slider.highHandle.currentValue))km")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
            .frame(
                width:
                    slider.doubleKnob ? screenWidth * 0.09 : screenWidth * 0.14,
                height:
                    screenWidth * 0.07
            )
            
            Spacer()
            
            RoundedRectangle(cornerRadius: slider.lineWidth)
                .fill(Color.accent) //.opacity(0.2)
                .frame(width: slider.width, height: slider.lineWidth)
                .overlay(
                    ZStack {
                        //Path between both handles
                        SliderPathBetweenView(slider: slider)
                        
                        if slider.doubleKnob {
                            //Low Handle
                            SliderHandleView(handle: slider.lowHandle!)
                                .highPriorityGesture(slider.lowHandle!.sliderDragGesture)
                        }
                        
                        
                        //High Handle
                        SliderHandleView(handle: slider.highHandle)
                            .highPriorityGesture(slider.highHandle.sliderDragGesture)
                    }
                )
            
            Spacer()
            
            ZStack{
                RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 1)
                    .foregroundColor(.accent)
                if slider.doubleKnob {
                    Text("\(Int(max(slider.highHandle.currentValue, slider.lowHandle!.currentValue)))y")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
            .frame(
                width:
                    screenWidth * 0.09,
                height:
                    screenWidth * 0.07
            )
            .opacity(slider.doubleKnob ? 1 : 0)
            
        }
        .frame(width: screenWidth * 0.95)
    }
}

struct SliderHandleView: View {
    @ObservedObject var handle: SliderHandle
    
    var body: some View {
        Circle()
            .frame(width: handle.diameter, height: handle.diameter)
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 0)
            .scaleEffect(handle.onDrag ? 1.3 : 1)
            .contentShape(Rectangle())
            .position(x: handle.currentLocation.x, y: handle.currentLocation.y)
    }
}

struct SliderPathBetweenView: View {
    @ObservedObject var slider: CustomSlider
    
    var body: some View {
        Path { path in
            if slider.doubleKnob {
                path.move(to: slider.lowHandle!.currentLocation)
            } else {
                path.move(to:CGPoint(x: (CGFloat(0.0)/1.0) * slider.highHandle.sliderWidth, y: slider.highHandle.sliderHeight / 2))
            }
            
            path.addLine(to: slider.highHandle.currentLocation)
        }
        .stroke(Color.buttonPrimary, lineWidth: slider.lineWidth)
    }
}
