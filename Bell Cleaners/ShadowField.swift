//
//  ShadowField.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/26/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class ShadowField: UITextField {
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    private func setup() {
        layer.borderColor = Constants.Colors.BellGreen.cgColor
        layer.borderWidth = Constants.Layers.BorderWidth
        layer.cornerRadius = Constants.Layers.CornerRadius
        layer.shadowColor = Constants.Layers.ShadowColor
        layer.shadowOffset = Constants.Layers.textFieldShadowOffset
        layer.shadowOpacity = Constants.Layers.textFieldShadowOpacity
        layer.shadowRadius = Constants.Layers.textFieldShadowRadius
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: Constants.CGRects.Dx, dy: Constants.CGRects.Dy)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: Constants.CGRects.Dx, dy: Constants.CGRects.Dy)
    }
}

class EmailField: ShadowField {
    
    func validate(field: UITextField) -> String? {
        guard let trimmedText = field.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        guard let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return nil
        }
        let range = NSMakeRange(Constants.Validations.Email.RangeLocation, NSString(string: trimmedText).length)
        let allMatches = dataDetector.matches(in: trimmedText,
                                              options: [],
                                              range: range)
        if allMatches.count == Constants.Validations.Email.MatchesCount,
            allMatches.first?.url?.absoluteString.contains(Constants.Literals.MailTo) == true
        {
            return trimmedText
        }
        return nil
    }
}

class PasswordField: ShadowField {}

class CurrentPasswordField: ShadowField {}

class NewPasswordField: ShadowField {}

class FirstNameField: ShadowField {}

class LastNameField: ShadowField {}

class PhoneNumberField: ShadowField {}

class AddressField: ShadowField {}

class CityField: ShadowField {}

class ZipcodeField: ShadowField {}
