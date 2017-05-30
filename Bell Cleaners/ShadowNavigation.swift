//
//  ShadowNavigation.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/29/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class ShadowNavigation: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = bellColor
        self.navigationBar.tintColor = navigationBarTintColor
        self.navigationBar.layer.shadowColor = layerShadowColor
        self.navigationBar.layer.shadowOffset = layerShadowOffset
        self.navigationBar.layer.shadowOpacity = layerShadowOpacity
        self.navigationBar.layer.shadowRadius = layerShadowRadius
        self.navigationBar.layer.masksToBounds = false
        self.navigationBar.setValue(true, forKey: navigationBarKeyHidesShadow)
    }
}
