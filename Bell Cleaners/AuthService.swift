//
//  AuthService.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/28/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias Completion = (_ errorMessage: String?, _ data: AnyObject?) -> Void

class AuthService {
    private static let _instance = AuthService()
    
    static var instance: AuthService {
        return _instance
    }
    
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
            }
        })
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        if Auth.auth().currentUser == nil {
            print("User is signed out")
        }
    }
    
    func handleFirebaseError(error: NSError, onComplete: Completion?) {
        print(error.debugDescription)
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            switch (errorCode) {
            case .userNotFound:
                onComplete?("User not found", nil)
            case .invalidEmail:
                onComplete?("Invalid email address", nil)
            case .wrongPassword:
                onComplete?("Invalid password", nil)
            case .networkError:
                onComplete?("Problem with network connection", nil)
            case .emailAlreadyInUse, .credentialAlreadyInUse:
                onComplete?("Could not create account. Email already in use.", nil)
            default:
                onComplete?("There was a problem. Please try again.", nil)
            }
        }
    }
}




















