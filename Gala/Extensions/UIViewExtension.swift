//
//  UIViewExtension.swift
//  Gala
//
//  Created by Vaughn on 2021-08-14.
//

import SwiftUI

extension UIView {
    func blink() {
        self.alpha = 0.0;
        UIView.animate(withDuration: 0.5, //Time duration you want,
                       delay: 0.0,
                       options: [.curveEaseInOut, .autoreverse, .repeat],
                       animations: { [weak self] in self?.alpha = 1.0 },
                       completion: { [weak self] _ in self?.alpha = 0.0 })
    }
    
    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
}
