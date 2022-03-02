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
    var snaps: [Snap]
    @ObservedObject var chatsViewModel: ChatsViewModel
    
    var body: some View {
        ZStack {
            Image(uiImage: snaps[counter].img!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if counter == snaps.count - 1 {
                        show = false
                    } else {
                        counter += 1
                        chatsViewModel.openSnap(snap: snaps[counter])
                    }
                }
                .onAppear {
                    chatsViewModel.openSnap(snap: snaps[counter])
                }
        }
    }
}

struct IndividualSnapView: View {
    var snap: Snap
    @Binding var showSnap: Bool
    @State var tapped = false
    @ObservedObject var vm = IndividualSnapViewModel()
    
    var body: some View {
        ZStack {
            Image(uiImage: snap.img!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    vm.openSnap(snap: snap)
                    tapped = true
                    showSnap = false
                }
                .onDisappear {
                    if !tapped {
                        vm.openSnap(snap: snap)
                    }
                }
        }
    }
}

import Combine

class IndividualSnapViewModel: ObservableObject {
    
    init() {}
    
    private var cancellables: [AnyCancellable] = []
    
    func openSnap(snap: Snap) {
        SnapService.shared.openSnap(snap: snap)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("IndividualSnapViewModel: Failed to open snap")
                    print("IndividualSnapViewModel-err: \(e)")
                case .finished:
                    print("IndividualSnapViewModel: Finished opening snap")
                    print("IndividualSnapViewModel: Opened snap with id: \(snap.snapID_timestamp)")
                }
            } receiveValue: { _ in

            }.store(in: &cancellables)
    }
}
