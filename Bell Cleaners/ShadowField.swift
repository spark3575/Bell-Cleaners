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
        layer.borderColor = Constants.Colors.GreenMedium.cgColor
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
        let allMatches = dataDetector.matches(in: trimmedText, options: [], range: range)
        if allMatches.count == Constants.Validations.Email.MatchesCount, allMatches.first?.url?.absoluteString.contains(Constants.Literals.MailTo) == true {
            return trimmedText
        }
        return nil
    }
    
    func formatWithSecureText(email: String, formattedTextField: UITextField) {
        var characters = Array(email.characters)
        var count = email.characters.count
        var replaceCount = 0
        for x in 4..<count {
            if x < 10 {
                characters[x] = Constants.Literals.SecureText
            } else {
                replaceCount += 1
            }
        }
        count -= replaceCount
        formattedTextField.text = String(characters[0..<count])
    }
}

class PasswordField: ShadowField {
    
    func formatWithSecureText(password: String, email: String, formattedTextField: UITextField) {
        var charactersInPassword = Array(password.characters)
        let count = email.characters.count
        for _ in 0..<count {
            charactersInPassword.append(Constants.Literals.SecureText)
        }
        formattedTextField.text = String(charactersInPassword[0..<count])
    }
}

class CurrentPasswordField: ShadowField {}

class NewPasswordField: ShadowField {}

class FirstNameField: ShadowField {}

class LastNameField: ShadowField {}

class PhoneNumberField: ShadowField {}

class AddressField: ShadowField {}

class CityField: ShadowField {}

class ZipcodeField: ShadowField {}
