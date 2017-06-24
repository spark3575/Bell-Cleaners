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
                    let userData = [Constants.Literals.Email: email, Constants.Literals.Password: password]
                    DataService.instance.updateUser(uid: user.uid, userData: userData as [String: AnyObject])
                }
            }
        })
    }
    
    func sendVerificationEmail() {
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if let error = error {
                print(Constants.ErrorMessages.VerificationEmail + String(describing: error))
            }
        }
    }
    
    func updateEmail(to email: String, onComplete: Completion?) {
        Auth.auth().currentUser?.updateEmail(to: email) { (error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            }
        }
    }
    
    func updatePassword(to password: String, onComplete: Completion?) {
        Auth.auth().currentUser?.updatePassword(to: password) { (error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print(Constants.ErrorMessages.SignOut + String(describing: signOutError))
        }
    }
    
    private func handleFirebaseError(error: NSError, onComplete: Completion?) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            switch (errorCode) {
            case .userNotFound:
                onComplete?(Constants.ErrorMessages.UserNotFound, nil)
            case .invalidEmail:
                onComplete?(Constants.ErrorMessages.InvalidEmail, nil)
            case .wrongPassword:
                onComplete?(Constants.ErrorMessages.InvalidPassword, nil)
            case .networkError:
                onComplete?(Constants.ErrorMessages.NetworkConnection, nil)
            case .emailAlreadyInUse, .credentialAlreadyInUse:
                onComplete?(Constants.ErrorMessages.EmailAlreadyInUse, nil)
            case .requiresRecentLogin:
                onComplete?(Constants.ErrorMessages.RequiresRecentLogin, nil)
            default:
                onComplete?(Constants.ErrorMessages.Default, nil)
            }
        }
    }
}
