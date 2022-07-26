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
    //@State var counter: Int = 0
    @Binding var show: Bool
    //var snaps: [Snap]
    var snapViewModel: ChatsViewModel
    var uid: String
    @Binding var snap: Snap?
    
    var body: some View {
        ZStack {
            if let snap = snap {
                if let _ = snap.assetData {
                    if snap.isImage {
                        imagePreview
                    } else if !snap.isImage {
                        videoPreview
                    }
                } else {
                    ProgressView()
                }
            } else {
                ProgressView()
            }
        }
    }
    
    var videoPreview: some View {
        Text("")
    }
    
    var imagePreview: some View {
        assetSnapView(snap: snap!) {
            if snapViewModel.tempCounter == snapViewModel.getUnopenedSnaps(from: uid).count {
                show = false
            } else {
                snapViewModel.getSnap(for: uid)
            }
        } onDisappear: {
            if snapViewModel.tempCounter == snapViewModel.getUnopenedSnaps(from: uid).count {
                //we have viewed all the snaps
                
                if let msgs = snapViewModel.matchMessages[uid] {
                    if msgs[msgs.count - 1].openedDate != nil {
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

struct assetSnapView: View {
    var snap: Snap
    var onTap: () -> Void
    var onDisappear: () -> Void

    var body: some View {
        if let data = snap.assetData {
            if snap.isImage {
                Image(uiImage: UIImage(data: data)!)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture(perform: onTap)
                    .onDisappear(perform: onDisappear)
            } else if !snap.isImage {
                //the asset is a video, play the video
                
            }
        }
    }
}
