//
//  OrderCell.swift
//  Bell Cleaners
//
//  Created by Shin Park on 7/5/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class OrderCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var itemsDescriptionLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var shadowView: ShadowViewRounded!
    
    var order: Order!

    func configureCell(order: Order) {                
        self.order = order
        self.dateLabel.text = epochToLocalDateTime(epochDateTime: order.date)
        self.itemsLabel.text = order.items
        self.numberLabel.text = order.number
        self.statusLabel.text = order.status
        self.totalLabel.text = order.total
        guard order.status != Constants.Literals.PickedUpDate else {
            shadowView.backgroundColor = UIColor.lightGray
            return
        }
        guard order.status != Constants.Literals.ReadyDate else {
            shadowView.backgroundColor = Constants.Colors.GreenMedium
            return
        }
        shadowView.backgroundColor = Constants.Colors.GreenLight
    }
    
    func epochToLocalDateTime(epochDateTime: String) -> String {
        let dateTimeDouble: TimeInterval = Double(epochDateTime)!
        let date = NSDate(timeIntervalSince1970: dateTimeDouble)
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateTimeFormatter.timeStyle = DateFormatter.Style.short //Set time style
        let timeZone = TimeZone.autoupdatingCurrent.identifier as String
        dateTimeFormatter.timeZone = TimeZone(identifier: timeZone)
        let localDate = dateTimeFormatter.string(from: date as Date)
        return String(localDate)
        
    }
}
