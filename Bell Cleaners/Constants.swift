//
//  Constants.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/22/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

let bellColor = UIColor(red: 64.0 / 255.0, green: 170.0 / 255.0, blue: 107.0 / 255.0, alpha: 1.0)
let layerShadowColor = UIColor.black.cgColor
let layerShadowOffset = CGSize(width: 0, height: 2.0)
let layerShadowOpacity: Float = 0.5
let layerShadowRadius: CGFloat = 4.0
let layerCornerRadius: CGFloat = 10.0
let delayAfterViewAppears = 0.5
let animationKeyPath = "transform.rotation"
let shakeFromValue = 0.0
let shakeToValue = -(CGFloat.pi / 3)
let shakeDuration = 0.3
let shakeRepeatCount: Float = 2
let bellSound = "dingSmallBell"
let mp3 = "mp3"
let bellPhoneNumberURL = URL(string: "tel://2143747007")
let bellLatitude = 32.705180
let bellLongitude = -96.799560
let bellSpanLatitudeDelta = 0.0027
let bellSpanLongitudeDelta = 0.0027
let bellAnnotationTitle = "Bell Cleaners"
let bellAnnotationSubtitle = "Expert Garment Care"
let userLat = 0.0
let userLon = 0.0
let decimalPlacesFormat = "%.5f"
let routeToBellURLPrefix = "http://maps.apple.com/?saddr="
let separatingComma = ","
let routeToBellURLSuffix = "&daddr=3508+S+Lancaster+Rd+75216"
let locationServiceAlertTitle = "Authorization Denied"
let locationServiceAlertMessage = "Location Services can be changed in your Privacy Settings"
let locationServiceAlertActionTitle = "OK"

