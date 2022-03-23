//
//  DraggableTextView.swift
//  Gala
//
//  Created by Vaughn on 2022-03-22.
//

import SwiftUI

struct DraggableTextView: View {
    @State var offset: CGSize = .zero
    @State var text = ""
    
    var body: some View {
        VStack {
//            RoundedRectangle(cornerRadius: 10)
//                .foregroundColor(.accent)
                //.opacity(0.3)
                
//            TextEditor(text: $text)
//                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.accent))
            //            Text(text).opacity(0).padding(.all, 8)
            Spacer()
            ZStack {
                TextEditor(text: $text)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .background(Color.blue)
            }
            
            Spacer()
        }
        .frame(width: screenWidth, height: screenHeight / 20)
        .offset(y: offset.height)
        .gesture(
            DragGesture()
                .onChanged({ value in
                    self.offset = value.translation
                })
        )
    }
}

struct DraggableTextView_Previews: PreviewProvider {
    static var previews: some View {
        DraggableTextView()
    }
}
