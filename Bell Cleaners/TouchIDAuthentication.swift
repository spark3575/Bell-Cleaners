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
    var biometricsError: NSError?
    
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
                var errorMessage = String()
                
                if self.biometricsError?.code == Int(kLAErrorBiometryNotAvailable) {
                    errorMessage = Constants.ErrorMessages.LABiometryNotAvailable
                }
                
                if self.biometricsError?.code == Int(kLAErrorBiometryNotEnrolled) {
                    errorMessage = Constants.ErrorMessages.LABiometryNotEnrolled
                }
                
                if self.biometricsError?.code == Int(kLAErrorBiometryLockout) {
                    errorMessage = Constants.ErrorMessages.LABiometryLockout
                }
                completion(errorMessage)
            }
        }
    }
}
