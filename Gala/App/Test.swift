//
//  Test.swift
//  Gala
//
//  Created by Vaughn on 2021-07-08.
//

import SwiftUI


struct Test: View {
    @State var offset: CGFloat = 0
    
    var body: some View {
        
        GeometryReader { proxy in
            let rect = proxy.frame(in: .global)
           
            Pager(tabs: tabs, rect: rect, offset: $offset) {
                
//                HStack(spacing: 0){
//                    ProfileMainView(viewModel: <#T##ProfileViewModel#>)
//                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
