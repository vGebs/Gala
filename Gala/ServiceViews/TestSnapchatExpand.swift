//
//  TestSnapchatExpand.swift
//  Gala
//
//  Created by Vaughn on 2022-01-27.
//

import SwiftUI

struct TestSnapchatExpand: View {
    
    var colors = [
        ColorStruct(color: .blue),
        ColorStruct(color: .red),
        ColorStruct(color: .yellow)
    ]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 2)
    
    @State var showVibe = false
    @State var offset: CGSize = .zero
    @State var scale: CGFloat = 1
    
    @State var selectedVibe: ColorStruct = ColorStruct()
    
    @Namespace var animation
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(colors) { color in
                        RoundedRectangle(cornerRadius: 20)
                            .matchedGeometryEffect(id: color.id, in: animation)
                            .scaleEffect(showVibe && selectedVibe.id == color.id ? scale : 1)
                            .frame(width: screenWidth / 2.2, height: screenWidth / 2.2)
                            .foregroundColor(color.color)
                            .opacity(showVibe && selectedVibe.id == color.id ? 0 : 1)
                            .onTapGesture {
                                withAnimation {
                                    self.showVibe = true
                                    self.selectedVibe = color
                                }
                            }
                            .zIndex(0)
                    }
                })
            }
            
            if showVibe {
                //selectedVibe.color
                TestSnapchat(showVibe: $showVibe)
                    .cornerRadius(20)
                    .scaleEffect(scale)
                    .matchedGeometryEffect(id: selectedVibe.id, in: animation)
                    .offset(self.offset)
                    .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnded(value:)))
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(3)
            }
        }
    }
    
    func onChanged(value: DragGesture.Value) {
        
        //only moves the view when user swipes down
        if value.translation.height > 50 {
            offset = value.translation
            
            //Scaling view
            let height = screenHeight - 50
            let progress = offset.height / height
            
            if 1 - progress > 0.5 {
                scale = 1 - progress
            }
        }
    }
    
    func onEnded(value: DragGesture.Value) {
        
        //resetting view
        withAnimation {
            
            if value.translation.height > 170 {
                showVibe = false
            }
            
            offset = .zero
            scale = 1
        }
    }
}

struct ColorStruct: Identifiable {
    let id = UUID()
    var color: Color?
}
