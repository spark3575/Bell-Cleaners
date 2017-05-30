//
//  ShadowButton.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/22/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class ShadowButton: UIButton {
    
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
        layer.cornerRadius = layerCornerRadius
    }
}

class AccessAccountButton: ShadowButton {}

class MapButton: ShadowButton {}

class DirectionsButton: ShadowButton {}

class SignInButton: ShadowButton {}

class SignUpButton: ShadowButton {}

class SignOutButton: ShadowButton {}

class OrdersButton: ShadowButton {}

class ProfileButton: ShadowButton {}

class SettingsButton: ShadowButton {}

class SupportButton: ShadowButton {}
