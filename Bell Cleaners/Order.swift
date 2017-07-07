//
//  Order.swift
//  Bell Cleaners
//
//  Created by Shin Park on 7/5/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import Foundation

class Order {
    
    private var _dateTime: String!
    private var _itemsCount: String!
    private var _orderID: String!
    private var _orderNumber: String!
    private var _orderStatus: String!
    private var _orderTotal: String!
    private var _userID: String!
    
    var dateTime: String {
        return _dateTime
    }
    
    var itemsCount: String {
        return _itemsCount
    }
    
    var orderID: String {
        return _orderID
    }
    
    var orderNumber: String {
        return _orderNumber
    }
    
    var orderStatus: String {
        return _orderStatus
    }
    
    var orderTotal: String {
        return _orderTotal
    }
    
    var userID: String {
        return _userID
    }
    
    init(dateTime: String, itemsCount: String, orderNumber: String, orderStatus: String, orderTotal: String, userID: String) {
        self._dateTime = dateTime
        self._itemsCount = itemsCount
        self._orderNumber = orderNumber
        self._orderStatus = orderStatus
        self._orderTotal = orderTotal
        self._userID = userID
    }
    
    init(orderID: String, orderData: [String: AnyObject]) {
        self._orderID = orderID
        if let dateTime = orderData["dateTime"] as? String {
            self._dateTime = dateTime
        }
        if let itemsCount = orderData["itemsCount"] as? String {
            self._itemsCount = itemsCount
        }
        if let orderNumber = orderData["orderNumber"] as? String {
            self._orderNumber = orderNumber
        }
        if let orderStatus = orderData["orderStatus"] as? String {
            self._orderStatus = orderStatus
        }
        if let orderTotal = orderData["orderTotal"] as? String {
            self._orderTotal = orderTotal
        }
        if let userID = orderData["userID"] as? String {
            self._userID = userID
        }
    }
}
