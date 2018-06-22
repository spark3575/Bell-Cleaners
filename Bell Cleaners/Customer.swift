//
//  Customer.swift
//  Bell Cleaners
//
//  Created by Shin Park on 7/10/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import Foundation

class Customer {
    
    private var _ableToAccessMyAccount: Bool!
    private var _address: String!
    private var _city: String!
    private var _email: String!
    private var _firstName: String!
    private var _ID: String!
    private var _lastName: String!
    private var _phoneNumber: String!
    private var _pickupDelivery: Bool!
    private var _userID: String!
    private var _zipcode: String!
    
    var ableToAccessMyAccount: Bool {
        return _ableToAccessMyAccount
    }
    
    var address: String {
        return _address
    }
    
    var city: String {
        return _city
    }
    
    var email: String {
        return _email
    }
    
    var firstName: String {
        return _firstName
    }
    
    var ID: String {
        return _ID
    }
    
    var lastName: String {
        return _lastName
    }
    
    var phoneNumber: String {
        return _phoneNumber
    }
    
    var pickupDelivery: Bool {
        return _pickupDelivery
    }
    
    var userID: String {
        return _userID
    }
    
    var zipcode: String {
        return _zipcode
    }
    
    init(phoneNumber: String, lastName: String, firstName: String) {
        self._phoneNumber = phoneNumber
        self._lastName = lastName
        self._firstName = firstName
    }
    
    init(customerData: [String: AnyObject]) {
        if let ableToAccessMyAccount = customerData[Constants.Literals.AbleToAccessMyAccount] as? Bool {
            self._ableToAccessMyAccount = ableToAccessMyAccount
        }
        if let address = customerData[Constants.Literals.Address] as? String {
            self._address = address
        }
        if let city = customerData[Constants.Literals.City] as? String {
            self._city = city
        }
        if let email = customerData[Constants.Literals.Email] as? String {
            self._email = email
        }
        if let firstName = customerData[Constants.Literals.FirstName] as? String {
            self._firstName = firstName
        }
        if let lastName = customerData[Constants.Literals.LastName] as? String {
            self._lastName = lastName
        }
        if let phoneNumber = customerData[Constants.Literals.PhoneNumber] as? String {
            self._phoneNumber = phoneNumber
        }
        if let pickupDelivery = customerData[Constants.Literals.PickupDelivery] as? Bool {
            self._pickupDelivery = pickupDelivery
        }
        if let userID = customerData[Constants.Literals.UserID] as? String {
            self._userID = userID
        }
        if let zipcode = customerData[Constants.Literals.Zipcode] as? String {
            self._zipcode = zipcode
        }
    }
    
    init(ID: String, customerData: [String: AnyObject]) {
        self._ID = ID
        if let ableToAccessMyAccount = customerData[Constants.Literals.AbleToAccessMyAccount] as? Bool {
            self._ableToAccessMyAccount = ableToAccessMyAccount
        }
        if let address = customerData[Constants.Literals.Address] as? String {
            self._address = address
        }
        if let city = customerData[Constants.Literals.City] as? String {
            self._city = city
        }
        if let email = customerData[Constants.Literals.Email] as? String {
            self._email = email
        }
        if let firstName = customerData[Constants.Literals.FirstName] as? String {
            self._firstName = firstName
        }
        if let lastName = customerData[Constants.Literals.LastName] as? String {
            self._lastName = lastName
        }
        if let phoneNumber = customerData[Constants.Literals.PhoneNumber] as? String {
            self._phoneNumber = phoneNumber
        }
        if let pickupDelivery = customerData[Constants.Literals.PickupDelivery] as? Bool {
            self._pickupDelivery = pickupDelivery
        }
        if let userID = customerData[Constants.Literals.UserID] as? String {
            self._userID = userID
        }
        if let zipcode = customerData[Constants.Literals.Zipcode] as? String {
            self._zipcode = zipcode
        }
    }
}
