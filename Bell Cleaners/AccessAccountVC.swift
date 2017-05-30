//
//  AccessAccountVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/25/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import FirebaseAuth

class AccessAccountVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: EmailField!
    @IBOutlet weak var passwordField: PasswordField!
    @IBOutlet weak var callBellButton: CallBellButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = accessAccountNavBarTitle
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    private let alertValidationFailed = PresentAlert()
    
    private func emailValidation(_ textField: UITextField) {
        if emailField.validate(field: emailField) != nil {
            textField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        } else {
            alertValidationFailed.presentAlert(fromController: self, title: emailAlertTitle, message: emailAlertMessage, actionTitle: okAlertActionTitle)
        }
    }
    
    private func passwordValidation(_ textField: UITextField) {
        if (textField.text?.characters.count)! >= passwordMinimumLength {
            textField.resignFirstResponder()
        } else {
            alertValidationFailed.presentAlert(fromController: self, title: passwordAlertTitle, message: passwordAlertMessage, actionTitle: okAlertActionTitle)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    @IBAction func didTapSignIn(_ sender: SignInButton) {
        if let email = emailField.text, let password = passwordField.text, (email.characters.count > 0 && password.characters.count > 0) {
            AuthService.instance.signIn(withEmail: email, password: password, onComplete: { (errorMessage, data) in
                guard errorMessage == nil else {
                    self.alertValidationFailed.presentAlert(fromController: self, title: authenticationAlertTitle, message: errorMessage!, actionTitle: okAlertActionTitle)
                    return
                }
                self.performSegue(withIdentifier: myAccountSegueIdentifier, sender: nil)
            })
        } else {
            alertValidationFailed.presentAlert(fromController: self, title: signInAlertTitle, message: signInAlertMessage, actionTitle: okAlertActionTitle)
        }
    }
    
    @IBAction func didTapSignUp(_ sender: SignUpButton) {
        if let email = emailField.text, let password = passwordField.text {
            AuthService.instance.createUser(withEmail: email, password: password, onComplete: { (errorMessage, data) in
                guard errorMessage == nil else {
                    self.alertValidationFailed.presentAlert(fromController: self, title: authenticationAlertTitle, message: errorMessage!, actionTitle: okAlertActionTitle)
                    return
                }
                self.performSegue(withIdentifier: signUpSegueIdentifier, sender: nil)
            })
        } else {
            alertValidationFailed.presentAlert(fromController: self, title: signUpAlertTitle, message: signUpAlertMessage, actionTitle: okAlertActionTitle)
        }
    }
    
    @IBAction func didTapCallBell(_ sender: CallBellButton) {
        callBellButton.callBell()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = emptyLeftBarButtonItemTitle
        navigationItem.backBarButtonItem = backButton
    }
}



















