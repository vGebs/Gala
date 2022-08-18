//
//  SnapView.swift
//  Gala
//
//  Created by Vaughn on 2022-02-24.
//

import SwiftUI
import OrderedCollections

protocol SnapProtocol {
    func openSnap(snap: Snap)
}

struct SnapView: View {
    @Binding var show: Bool
    @ObservedObject var snapViewModel: ChatsViewModel
    var uid: String
    @Binding var snap: Snap?
    
    var body: some View {
        ZStack {
            if let snap = snap {
                
                snapPreview
                
                if let caption = snap.caption {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.black)
                            .opacity(0.6)
                        Text(caption.captionText)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                    }
                    .frame(height: caption.textBoxHeight)
                    .position(x: screenWidth / 2, y: caption.yCoordinate)
                }
            } else {
                ProgressView()
            }
        }
    }
    
    var snapPreview: some View {
        assetSnapView(snap: snap!) {
            if snapViewModel.tempCounter == snapViewModel.getUnopenedSnaps(from: uid).count {
                show = false
            } else {
                snapViewModel.getSnap(for: uid)
            }
        } onDisappear: {
            if !show {
                if snapViewModel.tempCounter == snapViewModel.getUnopenedSnaps(from: uid).count {
                    //we have viewed all the snaps
                    
                    if let snaps = snapViewModel.matchMessages[uid] {
                        if snaps[snaps.count - 1].openedDate != nil {
                            snapViewModel.removeNotification(uid)
                        }
                    } else {
                        snapViewModel.removeNotification(uid)
                    }
                }
                
                snapViewModel.clearSnaps(for: uid)
            }
        }
    }
}

struct assetSnapView: View {
    var snap: Snap
    var onTap: () -> Void
    var onDisappear: () -> Void

    var body: some View {
        
        if let data = snap.imgAssetData {
            Image(uiImage: UIImage(data: data)!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .onTapGesture(perform: onTap)
                .onDisappear(perform: onDisappear)
        } else if let vidUrl = snap.vidURL {
            //the asset is a video, play the video
            //we are getting the video in data form, so we need to put it in a file
            PlayerView(url: vidUrl)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture(perform: onTap)
                .onDisappear(perform: onDisappear)
        }
    }
}
