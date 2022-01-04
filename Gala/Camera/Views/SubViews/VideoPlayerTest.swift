//
//  VideoPlayerTest.swift
//  Gala
//
//  Created by Vaughn on 2021-10-30.
//

import SwiftUI
import AVKit

struct VideoPlayerTest: View {
    var body: some View {
        VideoPlayer(player: AVPlayer(url:  URL(string: "https://bit.ly/swswift")!)) {
            VStack {
                Text("Watermark")
                    .foregroundColor(.black)
                    .background(Color.white.opacity(0.7))
                Spacer()
            }
            .frame(width: 400, height: 300)
        }
    }
}

struct VideoPlayerTest_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerTest()
    }
}
