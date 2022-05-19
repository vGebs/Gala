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
            if snap != nil {
                if snap!.img != nil {
                    Image(uiImage: snap!.img!)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            if snapViewModel.tempCounter == snapViewModel.getUnopenedSnaps(from: uid).count {
                                show = false
                            } else {
                                snapViewModel.getSnap(for: uid)
                            }
                        }
                        .onDisappear {
                            snapViewModel.clearSnaps(for: uid)
                        }
                } else {
                    ProgressView()
                }
            } else {
                ProgressView()
            }
        }
    }
}

struct IndividualSnapView: View {
    var snap: Snap
    @Binding var showSnap: Bool
    @State var tapped = false
    @ObservedObject var snapViewModel: ChatsViewModel
    
    var body: some View {
        ZStack {
            Image(uiImage: snap.img!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
//                    vm.openSnap(snap: snap)
//                    tapped = true
                    showSnap = false
                }
                .onDisappear {
                    snapViewModel.clearSnaps(for: snap.fromID)
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
