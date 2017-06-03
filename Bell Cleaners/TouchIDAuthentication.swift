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
            completion(canEvaluatePolicyMessage)
            return
        }
        context.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: touchLocalizedReason) { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    completion(nil)
                }
            } else {
                let message: String
                
                switch evaluateError {
                case LAError.authenticationFailed?:
                    message = touchLAErrorAuthentication
                case LAError.userCancel?:
                    message = touchLAErrorCancel
                case LAError.passcodeNotSet?:
                    message = touchLAErrorPasscode
                default:
                    message = touchLAErrorDefault
                }
                completion(message)
            }
        }
    }
}
