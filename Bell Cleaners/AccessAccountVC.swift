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
    @IBOutlet weak var createInfoLabel2: UILabel!
    @IBOutlet weak var callBellButton: CallBellButton!
    
    var passwordItems: [KeychainPasswordItem] = []
    let createAccountButtonTag = 0
    let signInButtonTag = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = accessAccountLiteral
        emailField.delegate = self
        passwordField.delegate = self
        
        let hasLogin = UserDefaults.standard.bool(forKey: hasLoginKeyLiteral)
        if hasLogin {
            signInButton.setTitle(buttonTitleSignIn, for: .normal)
            signInButton.tag = signInButtonTag
            createInfoLabel.isHidden = true
            createInfoLabel2.isHidden = true
            touchView.isHidden = !bellTouchSignIn.canEvaluatePolicy()
            touchButton.isHidden = !bellTouchSignIn.canEvaluatePolicy()
        } else {
            signInButton.setTitle(buttonTitleCreateAccount, for: .normal)
            signInButton.tag = createAccountButtonTag
            createInfoLabel.isHidden = false
            createInfoLabel2.isHidden = false
        }
        if let email = UserDefaults.standard.value(forKey: emailLiteral) as? String {
            emailField.text = email
        }
        
        if let hasTouched = UserDefaults.standard.value(forKey: hasUsedTouchKeyLiteral) as? Bool {
            if hasTouched == true {
                touchSignIn()
            }
        }
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
        
        if let email = emailField.text, let password = passwordField.text, !email.isEmpty && !password.isEmpty {
            
            if sender.tag == createAccountButtonTag {
                
                AuthService.instance.createUser(withEmail: email, password: password, onComplete: { (errorMessage, data) in
                    guard errorMessage == nil else {
                        self.alertValidationFailed.presentAlert(fromController: self, title: authenticationAlertTitle, message: errorMessage!, actionTitle: okAlertActionTitle)
                        return
                    }
                    let hasLoginKey = UserDefaults.standard.bool(forKey: hasLoginKeyLiteral)
                    if !hasLoginKey {
                        UserDefaults.standard.setValue(email, forKey: emailLiteral)
                    }
                    
                    do {
                        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                                account: emailLiteral,
                                                                accessGroup: KeychainConfiguration.accessGroup)
                        try passwordItem.savePassword(password)
                    } catch {
                        fatalError(keyChainFatalError + String(describing: error))
                    }
                    UserDefaults.standard.set(true, forKey: hasLoginKeyLiteral)
                    self.signInButton.tag = self.signInButtonTag
                    
                    self.performSegue(withIdentifier: signUpSegue, sender: self)
                })
            } else if sender.tag == signInButtonTag {
                
                if checkLogin(username: emailField.text!, password: passwordField.text!) {
                    
                    AuthService.instance.signIn(withEmail: email, password: password, onComplete: { (errorMessage, data) in
                        guard errorMessage == nil else {
                            self.alertValidationFailed.presentAlert(fromController: self, title: authenticationAlertTitle, message: errorMessage!, actionTitle: okAlertActionTitle)
                            return
                        }
                        if AuthService.profileFull == false {
                            self.performSegue(withIdentifier: signUpSegue, sender: self)
                            return
                        }
                        if AuthService.profileFull == true {
                            self.performSegue(withIdentifier: myAccountSegue, sender: self)
                            return
                        }
                        
                        self.performSegue(withIdentifier: accessAccountSegue, sender: self)
                    })
                } else {
                    alertValidationFailed.presentAlert(fromController: self, title: signInAlertTitle, message: signInAlertMessage, actionTitle: okAlertActionTitle)
                }
            }
        } else {
            alertValidationFailed.presentAlert(fromController: self, title: signInAlertTitle, message: signInAlertMessage, actionTitle: okAlertActionTitle)
        }
    }
    
    func checkLogin(username: String, password: String) -> Bool {
        
        guard username == UserDefaults.standard.value(forKey: emailLiteral) as? String else {
            return false
        }
        
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: emailLiteral,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            return password == keychainPassword
        }
        catch {
            fatalError(keyChainFatalError + String(describing: error))
        }
        
        return false
    }
    
    let bellTouchSignIn = TouchIDAuth()
    
    func touchSignIn() {
        
        if !bellTouchSignIn.canEvaluatePolicy() {
            self.alertValidationFailed.presentActionAlert(fromController: self, title: canEvaluatePolicyMessage, message: emptyLiteral, actionTitle: okAlertActionTitle)
        }
        
        bellTouchSignIn.authenticateUser() { message in
            
            if let message = message {
                if message == canEvaluatePolicyMessage, message == touchLAErrorPasscode {
                    self.alertValidationFailed.presentActionAlert(fromController: self, title: message, message: emptyLiteral, actionTitle: okAlertActionTitle)
                }
            } else {
                
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
                        
                        AuthService.instance.signIn(withEmail: email, password: password, onComplete: { (errorMessage, data) in
                            guard errorMessage == nil else {
                                self.alertValidationFailed.presentAlert(fromController: self, title: authenticationAlertTitle, message: errorMessage!, actionTitle: okAlertActionTitle)
                                return
                            }
                            if AuthService.profileFull == false {
                                self.performSegue(withIdentifier: signUpSegue, sender: self)
                                return
                            }
                            if AuthService.profileFull == true {
                                self.performSegue(withIdentifier: myAccountSegue, sender: self)
                                return
                            }
                            self.performSegue(withIdentifier: accessAccountSegue, sender: self)
                        })
                    }
                    catch {
                        fatalError(keyChainFatalError + String(describing: error))
                    }
                }
            }
        }
    }
    
    @IBAction func didTapTouch(_ sender: Any) {
        touchSignIn()
    }
    
    @IBAction func didTapCallBell(_ sender: CallBellButton) {
        callBellButton.callBell()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = emptyLiteral
        navigationItem.backBarButtonItem = backButton
    }
}
