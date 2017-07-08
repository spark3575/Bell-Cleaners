//
//  Order.swift
//  Bell Cleaners
//
//  Created by Shin Park on 7/5/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import Foundation

class Order {
    
    private var _date: String!
    private var _items: String!
    private var _ID: String!
    private var _number: String!
    private var _status: String!
    private var _total: String!
    private var _userID: String!
    
    var date: String {
        return _date
    }
    
    var items: String {
        return _items
    }
    
    var ID: String {
        return _ID
    }
    
    var number: String {
        return _number
    }
    
    var status: String {
        return _status
    }
    
    var total: String {
        return _total
    }
    
    var userID: String {
        return _userID
    }
    
    init(date: String, items: String, number: String, status: String, total: String, userID: String) {
        self._date = date
        self._items = items
        self._number = number
        self._status = status
        self._total = total
        self._userID = userID
    }
    
    init(ID: String, orderData: [String: AnyObject]) {
        self._ID = ID
        if let date = orderData[Constants.Literals.Date] as? String {
            self._date = date
        }
        if let items = orderData[Constants.Literals.Items] as? String {
            self._items = items
        }
        if let number = orderData[Constants.Literals.Number] as? String {
            self._number = number
        }
        if let status = orderData[Constants.Literals.Status] as? String {
            self._status = status
        }
        if let total = orderData[Constants.Literals.Total] as? String {
            self._total = total
        }
        if let userID = orderData[Constants.Literals.UserID] as? String {
            self._userID = userID
        }
    }
}
