//
//  Test.swift
//  Gala
//
//  Created by Vaughn on 2021-07-08.
//

import SwiftUI
import PageView

struct Test: View {
    @State var currentPage = 1
    var body: some View {
//        TabView {
//            Text("First")
//            Text("Second")
//            Text("Third")
//            Text("Fourth")
//        }
//        .tabViewStyle(PageTabViewStyle())
//        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
        ZStack {
            PageView(pageCount: 3, currentIndex: $currentPage) {
                ZStack {
                    Color.red
                    Text("1")
                }
                .edgesIgnoringSafeArea(.all)
                .frame(width: screenWidth, height: screenHeight)
                
                ZStack {
                    Color.blue
                    Text("2")
                }
                .edgesIgnoringSafeArea(.all)
                .frame(width: screenWidth, height: screenHeight)
                
                ZStack {
                    Color.yellow
                    Text("3")
                }
                .edgesIgnoringSafeArea(.all)
                .frame(width: screenWidth, height: screenHeight)
            }
            .hideIndicator(true)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
