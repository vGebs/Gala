//
//  SnapView.swift
//  Gala
//
//  Created by Vaughn on 2022-02-24.
//

import SwiftUI
import OrderedCollections

struct SnapView: View {
    @State var counter: Int = 0
    @Binding var show: Bool
    @Binding var userChat: UserChat?
    @Binding var snaps: OrderedDictionary<String, [Snap]>
    
    var body: some View {
        ZStack {
            Image(uiImage: snaps[userChat!.uid]![counter].img!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if counter == snaps[userChat!.uid]!.count - 1 {
                        show = false
                    } else {
                        counter += 1
                    }
                }
        }
    }
}

struct IndividualSnapView: View {
    var snap: Snap
    @Binding var showSnap: Bool
    var body: some View {
        ZStack {
            Image(uiImage: snap.img!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showSnap = false
                }
        }
    }
}
