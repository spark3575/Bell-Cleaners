//
//  OrderCell.swift
//  Bell Cleaners
//
//  Created by Shin Park on 7/5/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class OrderCell: UITableViewCell {
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var itemsCountLabel: UILabel!
    @IBOutlet weak var itemsDescriptionLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!    
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var orderTotalLabel: UILabel!
    
    var order: Order!

    func configureCell(order: Order) {
        self.order = order
        self.dateTimeLabel.text = order.dateTime
        self.itemsCountLabel.text = order.itemsCount
        self.orderNumberLabel.text = order.orderNumber
        self.orderStatusLabel.text = order.orderStatus
        self.orderTotalLabel.text = order.orderTotal
    }
}
