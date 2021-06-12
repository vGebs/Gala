//
//  AllRecentsView.swift
//  Gala
//
//  Created by Vaughn on 2021-06-11.
//

import SwiftUI

struct AllRecentsView: View {
    @Binding var allNewUsers: [ProfileModel]
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack {
                ForEach(allNewUsers){ user in
                    SmallUserView(viewModel: RecentlyJoinedViewModel(profile: user))
                        .padding(.bottom, 1.5)
                        .padding(.top, 1.5)
                        .frame(width: screenWidth)
                }
            }
        }
        .padding(.top, 20)
        .preferredColorScheme(.dark)
    }
}

struct AllRecentsView_Previews: PreviewProvider {
    static var previews: some View {
        AllRecentsView(allNewUsers: .constant(arr2))
    }
}
