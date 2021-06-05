//
//  StringExtension.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Combine
import Foundation

extension String {
    
    func isNameStringValid() -> AnyPublisher<Bool, Never> {
        return Just(self.count > 1).eraseToAnyPublisher()
    }
    
    func isEmailStringValid() -> AnyPublisher<Bool, Never> {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return Just(emailPred.evaluate(with: self) && self.count > 5).eraseToAnyPublisher()
    }
    
    func isCellNumberStringValid() -> AnyPublisher<Bool, Never> {
        return Just(self.count == 14).eraseToAnyPublisher()
    }
    
    func isPasswordStringValid() -> AnyPublisher<Bool, Never> {
        return Just(self.count > 5).eraseToAnyPublisher()
    }
    
    func isReEnterPasswordStringValid(_ reEnterPassword: String) -> AnyPublisher<Bool, Never> {
        return Just(self == reEnterPassword).eraseToAnyPublisher()
    }
}
