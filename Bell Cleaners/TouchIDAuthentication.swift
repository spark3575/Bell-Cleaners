//
//  TouchIDAuthentication.swift
//  Bell Cleaners
//
//  Created by Shin Park on 6/2/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import Foundation
import LocalAuthentication

class TouchIDAuth {
    
    let context = LAContext()
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authenticateUser(completion: @escaping (String?) -> Void) {
        guard canEvaluatePolicy() else {
            completion(Constants.ErrorMessages.TouchID)
            return
        }
        context.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: Constants.Literals.LocalizedReason) { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    completion(nil)
                }
            } else {
                let errorMessage: String
                
                switch evaluateError {
                case LAError.authenticationFailed?:
                    errorMessage = Constants.ErrorMessages.LAAuthentication
                case LAError.userCancel?:
                    errorMessage = Constants.ErrorMessages.LACancel
                case LAError.passcodeNotSet?:
                    errorMessage = Constants.ErrorMessages.LAPasscode
                default:
                    errorMessage = Constants.ErrorMessages.LADefault
                }
                completion(errorMessage)
            }
        }
    }
}
