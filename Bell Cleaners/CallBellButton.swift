//
//  CallBellButton.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/24/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class CallBellButton: ShadowButton {
    func callBell() {
        guard let number = bellPhoneNumberURL else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
    }
}
