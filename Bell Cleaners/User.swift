//
//  User.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/30/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

struct User {
    private var _uid: String
    private var _firstName: String
    private var _lastName: String
    private var _phoneNumber: String
    private var _email: String
    private var _password: String
    private var _pickupDelivery: String
    private var _address: String
    private var _city: String
    private var _zipcode: String
    
    var uid: String {
        return _uid
    }
    
    var firstName: String {
        return _firstName
    }
    
    var lastName: String {
        return _lastName
    }
    
    var phoneNumber: String {
        return _phoneNumber
    }
    
    var email: String {
        return _email
    }
    
    var password: String {
        return _password
    }
    
    var pickupDelivery: String {
        return _pickupDelivery
    }
    
    var address: String {
        return _address
    }
    
    var city: String {
        return _city
    }
    
    var zipcode: String {
        return _zipcode
    }
    
    init(uid: String, firstName: String, lastName: String, phoneNumber: String, email: String, password: String, pickupDelivery: String, address: String, city: String, zipcode: String) {
        _uid = uid
        _firstName = firstName
        _lastName = lastName
        _phoneNumber = phoneNumber
        _email = email
        _password = password
        _pickupDelivery = pickupDelivery
        _address = address
        _city = city
        _zipcode = zipcode
    }
}
