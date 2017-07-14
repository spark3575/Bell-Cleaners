//
//  CustomerCell.swift
//  Bell Cleaners
//
//  Created by Shin Park on 7/13/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class CustomerCell: UITableViewCell {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    private var customer: Customer!
    
    func configureCell(customer: Customer) {
        self.customer = customer
        self.fullNameLabel.text = customer.lastName + Constants.Literals.CommaSpace + customer.firstName
        self.phoneNumberLabel.text = customer.phoneNumber
    }
}
