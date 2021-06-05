//
//  ProfilePreview.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct ProfilePreview: View {
    var body: some View {
        ZStack {
            Image("me")
                .resizable()
                .clipShape(Circle())
                .aspectRatio(contentMode: .fit)
                .frame(width: screenWidth / 14, height: screenWidth / 14)
            
            Circle().stroke(lineWidth: 2)
                .foregroundColor(.white)
                .frame(width: screenWidth / 15, height: screenWidth / 15)
        }
    }
}

struct ProfilePreview_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePreview()
    }
}
