//
//  OrdersCell.swift
//  Bell Cleaners
//
//  Created by Shin Park on 7/5/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class OrdersCell: UITableViewCell {
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var itemsCountLabel: UILabel!
    @IBOutlet weak var itemsDescriptionLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!    
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var orderTotalLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
}
