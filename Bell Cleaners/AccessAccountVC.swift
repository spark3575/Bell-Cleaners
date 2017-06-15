//
//  AccessAccountVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/25/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

@IBDesignable
class AccessAccountVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var callBellButton: CallBellButton!
    @IBOutlet weak var emailField: emailShadowField!
    @IBOutlet weak var passwordField: passwordShadowField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
        
        addTapGestureRecognizer()
    }
    
    private let alertValidationFailed = PresentAlert()
    
    private func emailValidation(_ textField: UITextField) {
        if emailField.validate(field: emailField) != nil {
            textField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        } else {
            alertValidationFailed.presentAlert(fromController: self, title: emailValidationAlertTitle, message: emailValidationAlertMessage, actionTitle: okAlertActionTitle)
        }
    }
    
    private func passwordValidation(_ textField: UITextField) {
        if (textField.text?.characters.count)! >= passwordMinimumLength {
            textField.resignFirstResponder()
        } else {
            alertValidationFailed.presentAlert(fromController: self, title: passwordValidationAlertTitle, message: passwordValidationAlertMessage, actionTitle: okAlertActionTitle)
        }
    }
    
    private func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(AccessAccountVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.returnKeyType {
        case .next:
            emailValidation(textField)
        case .done:
            passwordValidation(textField)
        default:
            break
        }
        return true
    }
    
    @IBAction func loginPressed(_ sender: LoginButton) {
        
    }
    
    @IBAction func SignUpButton(_ sender: SignUpButton) {
        
    }
    
    @IBAction func callBellPressed(_ sender: CallBellButton) {
        callBellButton.callBell()
    }
}
