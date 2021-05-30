//
//  JigJagMomentStackViewRight.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct JigJagMomentStackViewRight: View {
    var body: some View {
        VStack{
            ForEach(moments.indices){ i in
                if i == 1{
                    GalaProAdvertisement()
                        .padding(.top, screenHeight * 0.01)
                    
                    MomentView(imageString: moments[i].imageString, name: moments[i].name, age: moments[i].age, title: moments[i].title)
                        //.padding(.top, moments.count % 2 != 0 ? screenHeight * 0.02 : screenHeight * 0.015)
                        .offset(y: screenHeight * -0.08)
                    
                } else if i % 2 != 0 {
                    if i == moments.count - 2{
                        MomentView(imageString: moments[i].imageString, name: moments[i].name, age: moments[i].age, title: moments[i].title)
                            .padding(.top, 5)
                            .offset(y: screenHeight * -0.06)

                        GalaProAdvertisement()
                            //.padding(.top, screenHeight * 0.04)
                            .offset(y: screenHeight * -0.02)

                    } else {
                        MomentView(imageString: moments[i].imageString, name: moments[i].name, age: moments[i].age, title: moments[i].title)
                            .padding(.top, 5)
                            .offset(y: screenHeight * -0.08)
                    }
                }
            }
        }.frame(width: screenWidth / 2.1)
    }
}

struct JigJagMomentStackViewRight_Previews: PreviewProvider {
    static var previews: some View {
        JigJagMomentStackViewRight()
    }
}
