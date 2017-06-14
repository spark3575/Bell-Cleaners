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
        layer.cornerRadius = Constants.Layers.CornerRadius
        layer.shadowColor = Constants.Layers.ShadowColor
        layer.shadowOffset = Constants.Layers.ShadowOffset
        layer.shadowOpacity = Constants.Layers.ShadowOpacity
        layer.shadowRadius = Constants.Layers.ShadowRadius
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.transform = CGAffineTransform(scaleX: Constants.Animations.Touch.ScaleX, y: Constants.Animations.Touch.ScaleY)
        UIView.animate(withDuration: Constants.Animations.Touch.Duration) {
            self.transform = CGAffineTransform.identity
        }
        super.touchesBegan(touches, with: event)
    }
}

class AccessAccountButton: ShadowButton {}

class MapButton: ShadowButton {}

class DirectionsButton: ShadowButton {}

class SignInButton: ShadowButton {}

class SignOutButton: ShadowButton {}

class SaveButton: ShadowButton {}

class OrdersButton: ShadowButton {}

class PickupDeliveryButton: ShadowButton {}

class ProfileButton: ShadowButton {}

class SettingsButton: ShadowButton {}

class SupportButton: ShadowButton {}
