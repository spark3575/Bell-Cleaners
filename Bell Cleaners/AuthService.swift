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
                    let userEmail = [Constants.Literals.Email: email]
                    DataService.instance.updateUser(uid: user.uid, userData: userEmail as [String: AnyObject])
                }
            }
        })
    }
    
    func reauthenticate(withEmail email: String, password: String, onComplete: Completion?) {
        let user = Auth.auth().currentUser
        let credential = (EmailAuthProvider.credential(withEmail: email, password: password))
        user?.reauthenticate(with: credential) { error in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, user)
            }
        }
    }
    
    func sendVerificationEmail(onComplete: Completion?) {
        let user = Auth.auth().currentUser
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, user)
            }
        }
    }
    
    func updateEmail(to email: String, onComplete: Completion?) {
        let user = Auth.auth().currentUser
        Auth.auth().currentUser?.updateEmail(to: email) { (error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, user)
            }
        }
    }
    
    func updatePassword(to password: String, onComplete: Completion?) {
        let user = Auth.auth().currentUser
        Auth.auth().currentUser?.updatePassword(to: password) { (error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, user)
            }
        }
    }
    
    func createProfileChangeRequest(name: String, onComplete: Completion?) {
        let user = Auth.auth().currentUser
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { (error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, user)
            }
        }
    }
    
    func sendPasswordReset(withEmail email: String, onComplete: Completion?) {
        let user = Auth.auth().currentUser
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, user)
            }
        }
    }
    
    func signOut(signedOut: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print(Constants.ErrorMessages.SignOut, signOutError)
        }
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                return
            } else {
                signedOut(true)
            }
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
