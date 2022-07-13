//
//  VideoPlayerView.swift
//  Gala
//
//  Created by Vaughn on 2022-07-08.
//

import Foundation
import SwiftUI
import AVFoundation
import AVKit

struct PlayerView: UIViewRepresentable {
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) { }

    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    }
}

class LoopingPlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Load the resource -> h
        //let fileUrl = Bundle.main.url(forResource: "NAME OF VIDEO", withExtension: "TYPE OF VIDEO")!
        
        //Load video
        let fileUrl = URL(fileURLWithPath: AppState.shared.cameraVM!.videoURL!)
        let asset = AVAsset(url: fileUrl)
        let item = AVPlayerItem(asset: asset)
        
        // Setup the player
        let player = AVQueuePlayer()
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.masksToBounds = true
        playerLayer.cornerRadius = 20
        
        layer.addSublayer(playerLayer)
        
        // Create a new player looper with the queue player and template item
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        // Start the movie
        player.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
