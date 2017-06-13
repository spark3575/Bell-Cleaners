//
//  AccessAccountVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/25/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import Firebase

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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var textStack: UIStackView!
    @IBOutlet weak var textStackTopConstraint: NSLayoutConstraint!
    
    private var passwordItems: [KeychainPasswordItem] = []
    private var securedTextEmail: String?
    private let alertValidationFailed = PresentAlert()
    private let bellTouchSignIn = TouchIDAuth()
    private let defaults = UserDefaults.standard
    private var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = accessAccountLiteral
        emailField.delegate = self
        passwordField.delegate = self
        if (defaults.bool(forKey: hasSignedInBeforeLiteral)) {
            if let email = defaults.string(forKey: emailLiteral) {
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
                securedTextEmail = emailField.text
                createInfoLabel.isHidden = true
            }
            touchView.isHidden = !bellTouchSignIn.canEvaluatePolicy()
            touchButton.isHidden = !bellTouchSignIn.canEvaluatePolicy()
            if (defaults.bool(forKey: hasUsedTouchKeyLiteral)) {
                touchSignIn()
            }
        } else {
            touchView.isHidden = true
            touchButton.isHidden = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        let targetY = view.frame.size.height - (keyboardFrame?.height)! - spaceTextToKeyboard - (activeField?.frame.size.height)!
        let textFieldY = textStack.frame.origin.y + (activeField?.frame.origin.y)!
        let difference = targetY - textFieldY
        let targetOffsetForTopConstraint = textStackTopConstraint.constant + difference
        view.layoutIfNeeded()
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.textStackTopConstraint.constant = targetOffsetForTopConstraint
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        view.layoutIfNeeded()
        UIView.animate(withDuration: keyboardDuration!) {
            self.textStackTopConstraint.constant = textStackTopConstraintOriginal
            self.view.layoutIfNeeded()
        }
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
    
    private func emailValidation(_ textField: UITextField) {
        if emailField.validate(field: emailField) != nil {
            textField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            alertValidationFailed.presentAlert(fromController: self, title: emailAlertTitle, message: emailAlertMessage, actionTitle: okAlertActionTitle)
        }
    }
    
    private func passwordValidation(_ textField: UITextField) {
        if (textField.text?.characters.count)! >= passwordMinimumLength {
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
            alertValidationFailed.presentAlert(fromController: self, title: passwordAlertTitle, message: passwordAlertMessage, actionTitle: okAlertActionTitle)
        }
    }
    
    private func signInUser(email: String, password: String) {
        var signInFailedAlert = UIAlertController(title: userNotFoundLiteral, message: createNewAccountLiteral, preferredStyle: .alert)
        var createAccountAction = UIAlertAction(title: createAccountLiteral, style: .default, handler: { action in
            self.signInButton.setTitle(createAccountLiteral, for: .normal)
            self.emailField.text = emptyLiteral
            self.passwordField.text = emptyLiteral
            self.touchButton.isHidden = true
            self.createInfoLabel.isHidden = true
        })
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .default, handler: nil)        
        AuthService.instance.signIn(withEmail: email, password: password, onComplete: { (errorMessage, data) in
            if errorMessage == userNotFoundErrorMessage {
                if !(self.defaults.bool(forKey: hasSignedInBeforeLiteral)) {
                    createAccountAction = UIAlertAction(title: createAccountLiteral, style: .default, handler: { action in
                        self.createUser(email: email, password: password)
                    })
                }
                self.defaults.set(false, forKey: hasUsedTouchKeyLiteral)
                signInFailedAlert.addAction(createAccountAction)
                signInFailedAlert.addAction(cancelAction)
                self.present(signInFailedAlert, animated: true, completion: nil)
                return
            }
            guard errorMessage == nil else {
                signInFailedAlert = UIAlertController(title: signInAlertTitle, message: errorMessage, preferredStyle: .alert)
                signInFailedAlert.addAction(createAccountAction)
                signInFailedAlert.addAction(cancelAction)
                self.present(signInFailedAlert, animated: true, completion: nil)
                return
            }
            self.saveLogin(email: email, password: password)
            DataService.instance.currentUserRef.observe(.value, with: { (snapshot) in
                if let user = snapshot.value as? [String : AnyObject] {
                    let ableToAccess = user[ableToAccessMyAccountLiteral] ?? false as AnyObject
                    let ableToAccessMyAccount = (ableToAccess as! Bool)
                    self.defaults.set(ableToAccessMyAccount, forKey: ableToAccessMyAccountLiteral)
                }
                self.spinner.stopAnimating()
                if (self.defaults.bool(forKey: ableToAccessMyAccountLiteral)) {
                    self.performSegue(withIdentifier: myAccountSegue, sender: self)
                    return
                } else {
                    self.performSegue(withIdentifier: profileSegue, sender: self)
                }
            })
        })
    }
    
    private func createUser(email: String, password: String) {
        AuthService.instance.createUser(withEmail: email, password: password, onComplete: { (errorMessage, data) in
            guard errorMessage == nil else {
                self.alertValidationFailed.presentAlert(fromController: self, title: authenticationAlertTitle, message: errorMessage!, actionTitle: okAlertActionTitle)
                return
            }
            self.saveLogin(email: email, password: password)
            self.performSegue(withIdentifier: profileSegue, sender: self)
        })
    }
    
    private func saveLogin(email: String, password: String) {
        defaults.setValue(email, forKey: emailLiteral)
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: emailLiteral,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(password)
        } catch {
            fatalError(keyChainFatalError + String(describing: error))
        }
        defaults.set(true, forKey: hasSignedInBeforeLiteral)
    }
    
    private func touchSignIn() {
        if bellTouchSignIn.canEvaluatePolicy() {
            bellTouchSignIn.authenticateUser() { message in
                if let message = message {
                    if message == canEvaluatePolicyMessage, message == touchLAErrorPasscode {
                        self.alertValidationFailed.presentSettingsActionAlert(fromController: self, title: message, message: touchSettingsMessage, actionTitle: okAlertActionTitle)
                    }
                } else {
                    if (self.defaults.bool(forKey: hasSignedInBeforeLiteral)) {
                        if let email = self.defaults.string(forKey: emailLiteral) {
                            self.spinner.startAnimating()
                            var password = emptyLiteral
                            
                            do {
                                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                                        account: emailLiteral,
                                                                        accessGroup: KeychainConfiguration.accessGroup)
                                password = try passwordItem.readPassword()
                                self.defaults.set(true, forKey: hasUsedTouchKeyLiteral)
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
            self.alertValidationFailed.presentSettingsActionAlert(fromController: self, title: canEvaluatePolicyMessage, message: touchSettingsMessage, actionTitle: okAlertActionTitle)
        }
    }
    
    @IBAction func didTapSignIn(_ sender: SignInButton) {
        if let email = emailField.text, let password = passwordField.text, !email.isEmpty && !password.isEmpty {
            spinner.startAnimating()
            if signInButton.currentTitle == signInLiteral {
                if (defaults.bool(forKey: hasSignedInBeforeLiteral)) {
                    if securedTextEmail == email {
                        if let savedEmail = defaults.string(forKey: emailLiteral) {
                            signInUser(email: savedEmail, password: password)
                        }
                    } else {
                        signInUser(email: email, password: password)
                    }
                    defaults.set(false, forKey: hasUsedTouchKeyLiteral)
                    return
                } else {
                    signInUser(email: email, password: password)
                    defaults.set(false, forKey: hasUsedTouchKeyLiteral)
                }
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
