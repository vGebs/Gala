//
//  JigJagMomentStackVIewLeft.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct JigJagMomentStackVIewLeft: View {
    var body: some View {
        VStack{
            ForEach(moments.indices){ i in
                if i == 0 || i % 2 == 0{
                    if i == moments.count - 2{
                        MomentView(imageString: moments[i].imageString, name: moments[i].name, age: moments[i].age, title: moments[i].title)
                            .padding(.top, 5)

                        GalaProAdvertisement()
                            .padding(.top, screenHeight * 0.03)
                    } else {
                        MomentView(imageString: moments[i].imageString, name: moments[i].name, age: moments[i].age, title: moments[i].title)
                            .padding(.top, 5)
                    }
                    
                }
            }
            Spacer()
        }.frame(width: screenWidth / 2.1)
    }
}

struct JigJagMomentStackVIewLeft_Previews: PreviewProvider {
    static var previews: some View {
        JigJagMomentStackVIewLeft()
    }
}
