//
//  ShadowView.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/22/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

@IBDesignable
class ShadowView: UIView {

    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    private func setup() {
        layer.shadowColor = layerShadowColor
        layer.shadowOffset = layerShadowOffset
        layer.shadowOpacity = layerShadowOpacity
        layer.shadowRadius = layerShadowRadius
    }
}
