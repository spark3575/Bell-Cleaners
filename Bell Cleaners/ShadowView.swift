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
    
    private func setup() {
        layer.shadowColor = Constants.Layers.ShadowColor
        layer.shadowOffset = Constants.Layers.ShadowOffset
        layer.shadowOpacity = Constants.Layers.ShadowOpacity
        layer.shadowRadius = Constants.Layers.ShadowRadius
    }
}

class ShadowViewRounded: ShadowView {
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = Constants.Layers.CornerRadius
        layer.shadowColor = Constants.Layers.ShadowColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowOpacity = Constants.Layers.ShadowOpacity
        layer.shadowRadius = CGFloat(2.0)
    }
}
