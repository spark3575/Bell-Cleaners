//
//  ConstantsBell.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/31/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import Foundation

let bellPhoneNumberURL = URL(string: "tel://2143747007")
let bellLatitude = 32.705250
let bellLongitude = -96.799470
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
let locationAlertTitle = "Location Services Required"
let locationAlertMessage = "Authorization can be changed in your Privacy Settings"
let settingsAlertActionTitle = "Settings"
let okAlertActionTitle = "OK"
let emailValidationContaining = "mailto:"
let emailAlertTitle = "Valid Email Address Required"
let emailAlertMessage = "Verification email will be sent"
let passwordMinimumLength = 6
let passwordAlertTitle = "Password Required"
let passwordAlertMessage = "Enter atleast 6 characters"
let authenticationAlertTitle = "Authentication Error"
let signInAlertTitle = "Sign In Error"
let signInAlertMessage = "Please check your email address or password"
let signUpAlertTitle = "Sign Up Error"
let signUpAlertMessage = "Please check your email address or password"
let bellCleanersSegue = "BellCleanersVC"
let accessAccountSegue = "AccessAccountVC"
let myAccountSegue = "MyAccountVC"
let signUpSegue = "SignUpVC"
