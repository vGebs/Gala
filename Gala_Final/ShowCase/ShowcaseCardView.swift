//
//  ShowcaseCardView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-10.
//

import Foundation
import SwiftUI

struct ShowcaseCardView: View {
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .frame(width: screenWidth * 0.9, height: screenHeight * 0.6)
                .foregroundColor(.pink)
        }
    }
}

struct ShowcaseCardView_Previews: PreviewProvider {
    static var previews: some View {
        ShowcaseCardView()
    }
}
