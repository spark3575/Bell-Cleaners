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
        return mainRef.child(Constants.Literals.Users)
    }
    
    var ordersRef: DatabaseReference {
        return mainRef.child(Constants.Literals.Orders)
    }
    
    var currentUserRef: DatabaseReference {
        return usersRef.child((Auth.auth().currentUser?.uid)!).child(Constants.Literals.Profile)
    }
    
    var currentUserOrders: DatabaseReference {
        return usersRef.child((Auth.auth().currentUser?.uid)!).child(Constants.Literals.Orders)
    }
    
    func updateDBUser(uid: String, userData: [String: AnyObject]) {
        mainRef.child(Constants.Literals.Users).child(uid).child(Constants.Literals.Profile).updateChildValues(userData)
    }
}
