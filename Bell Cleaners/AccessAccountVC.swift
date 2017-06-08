//
//  AccessAccountVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/25/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import FirebaseAuth

struct KeychainConfiguration {
    static let serviceName = bellCleanersLiteral
    static let accessGroup: String? = nil
}

class AccessAccountVC: UIViewController, UITextFieldDelegate {    
    @IBOutlet weak var emailField: EmailField!
    @IBOutlet weak var passwordField: PasswordField!
    @IBOutlet weak var signInButton: SignInButton!
    @IBOutlet weak var touchView: UIView!
    @IBOutlet weak var touchButton: UIButton!
    @IBOutlet weak var createInfoLabel: UILabel!
    @IBOutlet weak var callBellButton: CallBellButton!
    
    private var passwordItems: [KeychainPasswordItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = accessAccountLiteral
        emailField.delegate = self
        passwordField.delegate = self
        
        if UserDefaults.standard.value(forKey: hasSignedInBeforeLiteral) as? Bool == true {
            if let email = UserDefaults.standard.value(forKey: emailLiteral) as? String {
                var characters = Array(email.characters)
                var count = email.characters.count
                var replaceCount = 0
                for x in 4..<count {
                    if x < 10 {
                        characters[x] = secureTextLiteral
                    } else {
                        replaceCount += 1
                    }
                }
                count -= replaceCount
                emailField.text = String(characters[0..<count])
            }
            touchView.isHidden = !bellTouchSignIn.canEvaluatePolicy()
            touchButton.isHidden = !bellTouchSignIn.canEvaluatePolicy()
            if let hasTouched = UserDefaults.standard.value(forKey: hasUsedTouchKeyLiteral) as? Bool {
                if hasTouched {
                    touchSignIn()
                }
            }
        } else {
            touchView.isHidden = true
            touchButton.isHidden = true
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
    
    private func signInUser(email: String, password: String) {
        AuthService.instance.signIn(withEmail: email, password: password, onComplete: { (errorMessage, data) in
            if errorMessage == userNotFoundErrorMessage {
                let signInFailedAlert = UIAlertController(title: userNotFoundLiteral, message: createOneNowLiteral, preferredStyle: .alert)
                let createAccountAction = UIAlertAction(title: createAccountLiteral, style: .default, handler: { action in
                    self.createUser(email: email, password: password)
                })
                let cancelAction = UIAlertAction(title: cancelActionTitle, style: .default, handler: nil)
                let okAction = UIAlertAction(title: okAlertActionTitle, style: .default, handler: nil)
                let hasUsedTouch = UserDefaults.standard.bool(forKey: hasUsedTouchKeyLiteral)
                if !hasUsedTouch {
                    signInFailedAlert.addAction(createAccountAction)
                } else {
                    self.signInButton.setTitle(createAccountLiteral, for: .normal)
                    self.touchButton.isHidden = true
                    self.createInfoLabel.isHidden = true
                    UserDefaults.standard.set(false, forKey: hasUsedTouchKeyLiteral)
                    signInFailedAlert.addAction(okAction)
                    self.present(signInFailedAlert, animated: true, completion: nil)
                    return
                }
                signInFailedAlert.addAction(cancelAction)
                self.present(signInFailedAlert, animated: true, completion: nil)
                return
            }
            guard errorMessage == nil else {
                self.alertValidationFailed.presentAlert(fromController: self, title: authenticationAlertTitle, message: errorMessage!, actionTitle: okAlertActionTitle)
                return
            }
            let hasSignedInBefore = UserDefaults.standard.bool(forKey: hasSignedInBeforeLiteral)
            if !hasSignedInBefore {
                self.saveLogin(email: email, password: password)
            }            
            if !AuthService.profileFull {
                self.performSegue(withIdentifier: signUpSegue, sender: self)
                return
            }
            if AuthService.profileFull {
                self.performSegue(withIdentifier: myAccountSegue, sender: self)
                return
            }
        })
    }
    
    private func createUser(email: String, password: String) {
        AuthService.instance.createUser(withEmail: email, password: password, onComplete: { (errorMessage, data) in
            guard errorMessage == nil else {
                self.alertValidationFailed.presentAlert(fromController: self, title: authenticationAlertTitle, message: errorMessage!, actionTitle: okAlertActionTitle)
                return
            }
            self.saveLogin(email: email, password: password)
            self.performSegue(withIdentifier: signUpSegue, sender: self)
        })
    }
    
    private func saveLogin(email: String, password: String) {
        UserDefaults.standard.setValue(email, forKey: emailLiteral)
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: emailLiteral,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(password)
        } catch {
            fatalError(keyChainFatalError + String(describing: error))
        }
        let hasSignedInBefore = UserDefaults.standard.bool(forKey: hasSignedInBeforeLiteral)
        if !hasSignedInBefore {
            UserDefaults.standard.set(true, forKey: hasSignedInBeforeLiteral)
        }
    }
    
    private let bellTouchSignIn = TouchIDAuth()
    
    private func touchSignIn() {
        if bellTouchSignIn.canEvaluatePolicy() {
            bellTouchSignIn.authenticateUser() { message in
                if let message = message {
                    if message == canEvaluatePolicyMessage, message == touchLAErrorPasscode {
                        self.alertValidationFailed.presentSettingsActionAlert(fromController: self, title: message, message: emptyLiteral, actionTitle: okAlertActionTitle)
                    }
                } else {
                    let hasSignedInBefore = UserDefaults.standard.bool(forKey: hasSignedInBeforeLiteral)
                    if hasSignedInBefore {
                        if let email = UserDefaults.standard.value(forKey: emailLiteral) as? String {
                            var password = emptyLiteral
                            
                            do {
                                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                                        account: emailLiteral,
                                                                        accessGroup: KeychainConfiguration.accessGroup)
                                password = try passwordItem.readPassword()
                                
                                let hasUsedTouch = UserDefaults.standard.bool(forKey: hasUsedTouchKeyLiteral)
                                if !hasUsedTouch {
                                    UserDefaults.standard.set(true, forKey: hasUsedTouchKeyLiteral)
                                }
                                self.signInUser(email: email, password: password)
                            }
                            catch {
                                fatalError(keyChainFatalError + String(describing: error))
                            }
                        }
                    }
                }
            }
        } else {
            self.alertValidationFailed.presentSettingsActionAlert(fromController: self, title: canEvaluatePolicyMessage, message: emptyLiteral, actionTitle: okAlertActionTitle)
        }
    }
    
    @IBAction func didTapSignIn(_ sender: SignInButton) {
        if let email = emailField.text, let password = passwordField.text, !email.isEmpty && !password.isEmpty {
            if signInButton.currentTitle == signInLiteral {
                let hasSignedInBefore = UserDefaults.standard.bool(forKey: hasSignedInBeforeLiteral)
                if hasSignedInBefore {
                    if let savedEmail = UserDefaults.standard.value(forKey: emailLiteral) as? String {
                        signInUser(email: savedEmail, password: password)
                    }
                    return
                }
                let hasUsedTouch = UserDefaults.standard.bool(forKey: hasUsedTouchKeyLiteral)
                if hasUsedTouch {
                    UserDefaults.standard.set(false, forKey: hasUsedTouchKeyLiteral)
                }
                signInUser(email: email, password: password)
            } else {
                self.createUser(email: email, password: password)
            }
        } else {
            if signInButton.currentTitle == signInLiteral {
                alertValidationFailed.presentAlert(fromController: self, title: signInAlertTitle, message: accountAlertMessage, actionTitle: okAlertActionTitle)
            } else {
                alertValidationFailed.presentAlert(fromController: self, title: createAccountAlertTitle, message: accountAlertMessage, actionTitle: okAlertActionTitle)
            }
        }
    }
    
    @IBAction func didTapTouch(_ sender: Any) {
        touchSignIn()
    }
    
    @IBAction func didTapCallBell(_ sender: CallBellButton) {
        callBellButton.callBell()
    }
}
