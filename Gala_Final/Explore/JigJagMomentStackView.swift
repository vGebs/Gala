//
//  JigJagMomentStackView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct JigJagMomentStackView: View {
    var body: some View {
        HStack{
            JigJagMomentStackVIewLeft()
            JigJagMomentStackViewRight()
        }
    }
}

struct JigJagMomentStackView_Previews: PreviewProvider {
    static var previews: some View {
        JigJagMomentStackView()
    }
}
