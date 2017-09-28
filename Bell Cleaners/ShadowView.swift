//
//  ShadowView.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/22/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    func setup() {
        layer.shadowColor = Constants.Layers.ShadowColor
        layer.shadowOffset = Constants.Layers.ShadowOffset
        layer.shadowOpacity = Constants.Layers.ShadowOpacity
        layer.shadowRadius = Constants.Layers.ShadowRadius
        layer.backgroundColor = Constants.Colors.GreenHeavy.cgColor
    }
}

class ShadowViewBordered: ShadowView {
    
    override func setup() {
        layer.borderColor = Constants.Colors.GreenMedium.cgColor
        layer.borderWidth = Constants.Layers.BorderWidth
        layer.cornerRadius = Constants.Layers.CornerRadius
        layer.shadowColor = Constants.Layers.ShadowColor
        layer.shadowOffset = Constants.Layers.ShadowOffsetForRounded
        layer.shadowOpacity = Constants.Layers.ShadowOpacity
        layer.shadowRadius = Constants.Layers.ShadowRadiusForRounded
        layer.backgroundColor = Constants.Colors.GreenMedium.cgColor
    }
}

class ShadowViewRounded: ShadowView {
    
    override func setup() {
        layer.cornerRadius = Constants.Layers.CornerRadius
        layer.shadowColor = Constants.Layers.ShadowColor
        layer.shadowOffset = Constants.Layers.ShadowOffsetForRounded
        layer.shadowOpacity = Constants.Layers.ShadowOpacity
        layer.shadowRadius = Constants.Layers.ShadowRadiusForRounded
        layer.backgroundColor = Constants.Colors.GreenMedium.cgColor
    }
}
