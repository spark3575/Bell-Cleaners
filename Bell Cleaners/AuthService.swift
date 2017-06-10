//
//  AuthService.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/28/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import Foundation
import Firebase

typealias Completion = (_ errorMessage: String?, _ data: AnyObject?) -> Void

class AuthService {
    
    private static let _instance = AuthService()
    
    static var instance: AuthService {
        return _instance
    }
    
    static var profileFull = Bool()
    
    func signIn(withEmail email: String, password: String, onComplete: Completion?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, user)
            }
        })
    }
    
    func createUser(withEmail email: String, password: String, onComplete: Completion?) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, user)
                if let user = user {
                    let userData = [emailLiteral: email, passwordLiteral: password]
                    DataService.instance.updateUser(uid: user.uid, userData: userData as [String: AnyObject])
                }
            }
        })
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print(signOutErrorMessage + String(describing: signOutError))
        }
    }
    
    private func handleFirebaseError(error: NSError, onComplete: Completion?) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            switch (errorCode) {
            case .userNotFound:
                onComplete?(userNotFoundErrorMessage, nil)
            case .invalidEmail:
                onComplete?(invalidEmailErrorMessage, nil)
            case .wrongPassword:
                onComplete?(invalidPasswordErrorMessage, nil)
            case .networkError:
                onComplete?(networkConnectionErrorMessage, nil)
            case .emailAlreadyInUse, .credentialAlreadyInUse:
                onComplete?(createAccountErrorMessage, nil)
            default:
                onComplete?(defaultErrorMessage, nil)
            }
        }
    }
}
