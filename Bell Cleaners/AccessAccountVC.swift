//
//  AccessAccountVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/25/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import Firebase

class AccessAccountVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var callBellButton: CallBellButton!
    @IBOutlet weak var createInfoLabel: UILabel!
    @IBOutlet weak var emailField: EmailField!
    @IBOutlet weak var passwordField: PasswordField!
    @IBOutlet weak var signInButton: SignInButton!
    @IBOutlet weak var touchButton: UIButton!
    @IBOutlet weak var touchView: UIView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var textStack: UIStackView!
    @IBOutlet weak var textStackTopConstraint: NSLayoutConstraint!
    
    private var activeField: UITextField?
    private let alertValidationFailed = PresentAlert()
    private let bellTouchSignIn = TouchIDAuth()
    private let defaults = UserDefaults.standard
    private var handle: AuthStateDidChangeListenerHandle?
    private var passwordItems: [KeychainPasswordItem] = []
    private var securedTextEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        if (defaults.bool(forKey: Constants.DefaultsKeys.HasSignedInBefore)) {
            if let email = defaults.string(forKey: Constants.DefaultsKeys.Email) {
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
                emailField.text = String(characters[0..<count])
                securedTextEmail = emailField.text
                createInfoLabel.isHidden = true
            }
            touchView.isHidden = !bellTouchSignIn.canEvaluatePolicy()
            touchButton.isHidden = !bellTouchSignIn.canEvaluatePolicy()
            if (defaults.bool(forKey: Constants.DefaultsKeys.HasUsedTouch)) {
                touchSignIn()
            }
        } else {
            touchView.isHidden = true
            touchButton.isHidden = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // [START auth_listener]
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        Auth.auth().removeStateDidChangeListener(handle!)
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        let targetY = view.frame.size.height - (keyboardFrame?.height)! - Constants.Keyboards.SpaceToText - (activeField?.frame.size.height)!
        let textFieldY = textStack.frame.origin.y + (activeField?.frame.origin.y)!
        let difference = targetY - textFieldY
        let targetOffsetForTopConstraint = textStackTopConstraint.constant + difference
        view.layoutIfNeeded()
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.textStackTopConstraint.constant = targetOffsetForTopConstraint
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        view.layoutIfNeeded()
        UIView.animate(withDuration: keyboardDuration!) {
            self.textStackTopConstraint.constant = Constants.Keyboards.OriginalConstraint
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
            alertValidationFailed.presentAlert(fromController: self, title: Constants.Alerts.Titles.Email, message: Constants.Alerts.Messages.Email, actionTitle: Constants.Alerts.Actions.OK)
        }
    }
    
    private func passwordValidation(_ textField: UITextField) {
        if (textField.text?.characters.count)! >= Constants.Validations.Password.MinimumLength {
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
            alertValidationFailed.presentAlert(fromController: self, title: Constants.Alerts.Titles.Password, message: Constants.Alerts.Messages.Password, actionTitle: Constants.Alerts.Actions.OK)
        }
    }
    
    private func signInUser(email: String, password: String) {
        spinner.startAnimating()
        AuthService.instance.signIn(withEmail: email, password: password, onComplete: { (errorMessage, data) in
            self.spinner.stopAnimating()
            let signInFailedAlert = UIAlertController(title: Constants.Alerts.Titles.UserNotFound, message: Constants.Alerts.Messages.CreateNewAccount, preferredStyle: .alert)
            var createAccountAction = UIAlertAction(title: Constants.Alerts.Actions.CreateAccount, style: .default, handler: { action in
                self.signInButton.setTitle(Constants.Literals.CreateAccount, for: .normal)
                self.emailField.text = Constants.Literals.EmptyString
                self.passwordField.text = Constants.Literals.EmptyString
                self.touchButton.isHidden = true
                self.createInfoLabel.isHidden = true
            })
            let cancelAction = UIAlertAction(title: Constants.Alerts.Actions.Cancel, style: .default, handler: nil)
            if errorMessage == Constants.ErrorMessages.UserNotFound {
                if !(self.defaults.bool(forKey: Constants.DefaultsKeys.HasSignedInBefore)) {
                    createAccountAction = UIAlertAction(title: Constants.Alerts.Actions.CreateAccount, style: .default, handler: { action in
                        self.createUser(email: email, password: password)
                    })
                }
                self.defaults.set(false, forKey: Constants.DefaultsKeys.HasUsedTouch)
                signInFailedAlert.addAction(createAccountAction)
                signInFailedAlert.addAction(cancelAction)
                self.present(signInFailedAlert, animated: true, completion: nil)
                return
            }
            guard let _ = data, errorMessage == nil else {
                self.alertValidationFailed.presentAlert(fromController: self, title: Constants.Alerts.Titles.SignInFailed, message: errorMessage!, actionTitle: Constants.Alerts.Actions.OK)
                return
            }
            self.saveLogin(email: email, password: password)
            self.spinner.startAnimating()
            DataService.instance.currentUserRef.observe(.value, with: { (snapshot) in
                self.spinner.stopAnimating()
                if let user = snapshot.value as? [String : AnyObject] {
                    let ableToAccess = user[Constants.Literals.AbleToAccessMyAccount] ?? false as AnyObject
                    let ableToAccessMyAccount = (ableToAccess as! Bool)
                    self.defaults.set(ableToAccessMyAccount, forKey: Constants.DefaultsKeys.AbleToAccessMyAccount)
                    let userEmail = user[Constants.Literals.Email] ?? Constants.Literals.EmptyString as AnyObject
                    let email = userEmail as! String
                    if email == Constants.Literals.AdminEmail {
                        self.performSegue(withIdentifier: Constants.Segues.Admin, sender: self)
                        return
                    }
                }
                if (self.defaults.bool(forKey: Constants.DefaultsKeys.AbleToAccessMyAccount)) {
                    self.performSegue(withIdentifier: Constants.Segues.MyAccount, sender: self)
                    return
                } else {
                    self.performSegue(withIdentifier: Constants.Segues.Profile, sender: self)
                }
            })
        })
    }
    
    private func createUser(email: String, password: String) {
        spinner.startAnimating()
        AuthService.instance.createUser(withEmail: email, password: password, onComplete: { (errorMessage, data) in
            self.spinner.stopAnimating()
            guard let _ = data, errorMessage == nil else {
                self.alertValidationFailed.presentAlert(fromController: self, title: Constants.Alerts.Titles.CreateAccountFailed, message: errorMessage!, actionTitle: Constants.Alerts.Actions.OK)
                return
            }
            AuthService.instance.sendVerificationEmail()
            self.saveLogin(email: email, password: password)
            self.performSegue(withIdentifier: Constants.Segues.Profile, sender: self)
        })
    }
    
    private func saveLogin(email: String, password: String) {
        defaults.setValue(email, forKey: Constants.DefaultsKeys.Email)
        do {
            let passwordItem = KeychainPasswordItem(service: Constants.KeychainConfigurations.ServiceName,
                                                    account: Constants.KeychainConfigurations.Email,
                                                    accessGroup: Constants.KeychainConfigurations.AccessGroup)
            try passwordItem.savePassword(password)
        } catch {
            fatalError(Constants.ErrorMessages.KeyChain + String(describing: error))
        }
        defaults.set(true, forKey: Constants.DefaultsKeys.HasSignedInBefore)
    }
    
    private func touchSignIn() {
        if bellTouchSignIn.canEvaluatePolicy() {
            bellTouchSignIn.authenticateUser() { errorMessage in
                if let errorMessage = errorMessage {
                    if errorMessage == Constants.ErrorMessages.TouchID, errorMessage == Constants.ErrorMessages.LAPasscode {
                        self.alertValidationFailed.presentSettingsActionAlert(fromController: self, title: errorMessage, message: Constants.Alerts.Messages.TouchSettings, actionTitle: Constants.Alerts.Actions.OK)
                    }
                } else {
                    if (self.defaults.bool(forKey: Constants.DefaultsKeys.HasSignedInBefore)) {
                        if let email = self.defaults.string(forKey: Constants.DefaultsKeys.Email) {
                            var password = Constants.Literals.EmptyString
                            
                            do {
                                let passwordItem = KeychainPasswordItem(service: Constants.KeychainConfigurations.ServiceName,
                                                                        account: Constants.KeychainConfigurations.Email,
                                                                        accessGroup: Constants.KeychainConfigurations.AccessGroup)
                                password = try passwordItem.readPassword()
                                self.defaults.set(true, forKey: Constants.DefaultsKeys.HasUsedTouch)
                                self.signInUser(email: email, password: password)
                            }
                            catch {
                                fatalError(Constants.ErrorMessages.KeyChain + String(describing: error))
                            }
                        }
                    }
                }
            }
        } else {
            self.alertValidationFailed.presentSettingsActionAlert(fromController: self, title: Constants.Alerts.Titles.TouchID, message: Constants.Alerts.Messages.TouchSettings, actionTitle: Constants.Alerts.Actions.OK)
        }
    }
    
    @IBAction func didTapSignIn(_ sender: SignInButton) {
        if let email = emailField.text, let password = passwordField.text, !email.isEmpty && !password.isEmpty {
            if signInButton.currentTitle == Constants.Literals.SignIn {
                if (defaults.bool(forKey: Constants.DefaultsKeys.HasSignedInBefore)) {
                    if securedTextEmail == email {
                        if let savedEmail = defaults.string(forKey: Constants.DefaultsKeys.Email) {
                            signInUser(email: savedEmail, password: password)
                        }
                    } else {
                        signInUser(email: email, password: password)
                    }
                    return
                } else {
                    signInUser(email: email, password: password)
                }
                defaults.set(false, forKey: Constants.DefaultsKeys.HasUsedTouch)
            }
            if signInButton.currentTitle == Constants.Literals.CreateAccount {
                self.createUser(email: email, password: password)
            }
        } else {
            if signInButton.currentTitle == Constants.Literals.SignIn {
                alertValidationFailed.presentAlert(fromController: self, title: Constants.Alerts.Titles.SignInFailed, message: Constants.Alerts.Messages.CheckEmailPassword, actionTitle: Constants.Alerts.Actions.OK)
            } else {
                alertValidationFailed.presentAlert(fromController: self, title: Constants.Alerts.Titles.CreateAccountFailed, message: Constants.Alerts.Messages.CheckEmailPassword, actionTitle: Constants.Alerts.Actions.OK)
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
