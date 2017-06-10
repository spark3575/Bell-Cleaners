//
//  DataService.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/30/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    
    private static let _instance = DataService()
    
    static var instance: DataService {
        return _instance
    }
    
    var mainRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var usersRef: DatabaseReference {
        return mainRef.child(usersLiteral)
    }
    
    var currentUserRef: DatabaseReference {
        return usersRef.child((Auth.auth().currentUser?.uid)!).child(profileLiteral)
    }
    
    func updateUser(uid: String, userData: [String: AnyObject]) {
        mainRef.child(usersLiteral).child(uid).child(profileLiteral).updateChildValues(userData)
    }
}
