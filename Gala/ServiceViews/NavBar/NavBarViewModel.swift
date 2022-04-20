//
//  NavBarViewModel.swift
//  Gala
//
//  Created by Vaughn on 2022-03-29.
//

import SwiftUI
import Combine

class NavBarViewModel: ObservableObject {
    @Published var currentPage: CGFloat = screenWidth
    
    private var cancellables: [AnyCancellable] = []
    
    deinit {
        print("NavBarViewModel: Deinitializing")
    }
    
    init() {
        $currentPage
            .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .map { val in
                if val != screenWidth {
                    AppState.shared.cameraVM?.tearDownCamera()
                }
            }.sink { _ in }
            .store(in: &cancellables)
        
        $currentPage
            .map { val in
                if val == screenWidth {
                    AppState.shared.cameraVM?.buildCamera()
                }
            }.sink { _ in }
            .store(in: &cancellables)
    }
}
