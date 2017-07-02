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
    
    @IBOutlet weak var emailField: EmailField!
    @IBOutlet weak var passwordField: PasswordField!    
    @IBOutlet weak var signInButton: SignInButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var textViewStack: UIStackView!
    @IBOutlet weak var touchButton: UIButton!
    @IBOutlet weak var touchView: UIView!
    
    private var activeField: UITextField?
    private let alertAccessAccount = PresentAlert()
    private let bellTouchSignIn = TouchIDAuth()
    private let defaults = UserDefaults.standard
    private var keyboardManager: KeyboardManager?
    private let notification = NotificationCenter.default
    private var passwordItems: [KeychainPasswordItem] = []
    private var securedTextEmail: String?
    private var stackViewOriginY: CGFloat?
    private var userRefObserverHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        stackViewOriginY = view.frame.origin.y
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
                textViewStack.isHidden = true
            }
            touchView.isHidden = !bellTouchSignIn.canEvaluatePolicy()
            if (defaults.bool(forKey: Constants.DefaultsKeys.HasUsedTouch)) {
                touchSignIn()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !(defaults.bool(forKey: Constants.DefaultsKeys.HasSignedInBefore)) {
            emailField.text = Constants.Literals.EmptyString
            passwordField.text = Constants.Literals.EmptyString
            touchView.isHidden = true
            if (defaults.string(forKey: Constants.DefaultsKeys.Email)) == nil {
                textViewStack.isHidden = false
            } else {
                textViewStack.isHidden = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notification.removeObserver(self)
        DataService.instance.currentUserRef.removeObserver(withHandle: userRefObserverHandle)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        if activeField != nil {
            UIView.animate(withDuration: Constants.Animations.Keyboard.DurationHide, animations: {
                if let originY = self.stackViewOriginY {
                    self.stackView.frame.origin.y = originY
                    self.view.layoutIfNeeded()
                }
            })
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        keyboardManager = KeyboardManager(observer: self, viewOfVC: [view], stackViewToMove: [stackView], textFieldToMove: [activeField!], notifyFromObject: nil)
        keyboardManager?.viewMoveWhenKeyboardWillShow()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
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
            alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.ValidEmail, message: Constants.Alerts.Messages.VerificationEmail, actionTitle: Constants.Alerts.Actions.OK)
            self.view.layoutIfNeeded()
        }
    }
    
    private func passwordValidation(_ textField: UITextField) {
        if (textField.text?.characters.count)! >= Constants.Validations.Password.MinimumLength {
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
            alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.Password, message: Constants.Alerts.Messages.Password, actionTitle: Constants.Alerts.Actions.OK)
            self.view.layoutIfNeeded()
        }
    }
    
    private func signInUser(email: String, password: String) {
        spinner.startAnimating()
        AuthService.instance.signIn(withEmail: email, password: password, onComplete: { (errorMessage, user) in
            self.spinner.stopAnimating()
            var alertSignInFailed = UIAlertController(title: Constants.Alerts.Titles.UserNotFound, message: Constants.Alerts.Messages.CreateNewAccount, preferredStyle: .alert)
            if errorMessage == Constants.ErrorMessages.UserNotFound {
                var createAccountAction = UIAlertAction(title: Constants.Alerts.Actions.CreateAccount, style: .default, handler: { (action) in
                    self.signInButton.setTitle(Constants.Literals.CreateAccount, for: .normal)
                    self.emailField.text = Constants.Literals.EmptyString
                    self.passwordField.text = Constants.Literals.EmptyString
                    self.touchView.isHidden = true
                    self.textViewStack.isHidden = true
                })
                if !(self.defaults.bool(forKey: Constants.DefaultsKeys.HasSignedInBefore)) {
                    createAccountAction = UIAlertAction(title: Constants.Alerts.Actions.CreateAccount, style: .default, handler: { (action) in
                        self.createUser(email: email, password: password)
                    })
                }
                self.defaults.set(false, forKey: Constants.DefaultsKeys.HasUsedTouch)
                alertSignInFailed.addAction(createAccountAction)
                alertSignInFailed.addAction(UIAlertAction(title: Constants.Alerts.Actions.Cancel, style: .default, handler: nil))
                self.present(alertSignInFailed, animated: true, completion: nil)
                self.view.layoutIfNeeded()
                return
            }
            if errorMessage == Constants.ErrorMessages.InvalidPassword {
                alertSignInFailed = UIAlertController(title: Constants.Alerts.Titles.IncorrectPassword, message: Constants.Alerts.Messages.IncorrectPassword, preferredStyle: .alert)
                alertSignInFailed.addAction(UIAlertAction(title: Constants.Alerts.Actions.SendResetPasswordEmail, style: .default, handler: { (action) in
                    AuthService.instance.sendPasswordReset(withEmail: email)
                }))
                alertSignInFailed.addAction(UIAlertAction(title: Constants.Alerts.Actions.Cancel, style: .default, handler: nil))
                self.spinner.startAnimating()
                self.present(alertSignInFailed, animated: true, completion: {
                    Timer.scheduledTimer(withTimeInterval: Constants.TimerIntervals.FirebaseDelay, repeats: false) { (timer) in
                        self.alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.ResetPasswordEmailSent, message: Constants.Alerts.Messages.ResetPasswordEmailSent, actionTitle: Constants.Alerts.Actions.OK)
                    }
                })
                self.spinner.stopAnimating()                
                return
            }
            guard let _ = user, errorMessage == nil else {
                self.alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.SignInFailed, message: errorMessage!, actionTitle: Constants.Alerts.Actions.OK)
                return
            }
            self.saveLogin(email: email, password: password)
            if let user = Auth.auth().currentUser , user.isEmailVerified {
                self.spinner.startAnimating()
                self.userRefObserverHandle = DataService.instance.currentUserRef.observe(.value, with: { (snapshot) in
                    self.spinner.stopAnimating()
                    if let user = snapshot.value as? [String : AnyObject] {
                        let ableToAccess = user[Constants.Literals.AbleToAccessMyAccount] ?? false as AnyObject
                        let ableToAccessMyAccount = (ableToAccess as! Bool)
                        self.defaults.set(ableToAccessMyAccount, forKey: Constants.DefaultsKeys.AbleToAccessMyAccount)
                        let userEmail = user[Constants.Literals.Email] ?? Constants.Literals.EmptyString as AnyObject
                        let email = userEmail as! String
                        if email == Constants.Literals.AdminEmail {
                            self.performSegue(withIdentifier: Constants.Segues.AdminVC, sender: self)
                            return
                        }
                    }
                    if (self.defaults.bool(forKey: Constants.DefaultsKeys.AbleToAccessMyAccount)) {
                        self.performSegue(withIdentifier: Constants.Segues.MyAccountVC, sender: self)
                        return
                    } else {
                        self.performSegue(withIdentifier: Constants.Segues.ProfileVC, sender: self)
                    }
                })
            } else {
                let alertEmailVerification = UIAlertController(title: Constants.Alerts.Titles.EmailVerification, message: Constants.Alerts.Messages.CheckVerificationEmail, preferredStyle: .alert)
                if let user = Auth.auth().currentUser, !user.isEmailVerified {
                    alertEmailVerification.addAction(UIAlertAction(title: Constants.Alerts.Actions.SendVerificationEmail, style: .default, handler: { (action) in
                        AuthService.instance.sendVerificationEmail()
                    }))
                }
                alertEmailVerification.addAction(UIAlertAction(title: Constants.Alerts.Actions.OK, style: .default, handler: nil))
                self.present(alertEmailVerification, animated: true, completion: nil)
                self.view.layoutIfNeeded()
            }
        })
    }
    
    private func createUser(email: String, password: String) {
        spinner.startAnimating()
        AuthService.instance.createUser(withEmail: email, password: password, onComplete: { (errorMessage, user) in
            self.spinner.stopAnimating()
            guard let _ = user, errorMessage == nil else {
                self.alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.CreateAccountFailed, message: errorMessage!, actionTitle: Constants.Alerts.Actions.OK)
                self.view.layoutIfNeeded()
                return
            }
            self.signInButton.setTitle(Constants.Literals.SignIn, for: .normal)
            self.textViewStack.isHidden = true
            AuthService.instance.sendVerificationEmail()
            self.saveLogin(email: email, password: password)
            self.alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.CreateAccountSuccesful, message: Constants.Alerts.Messages.CheckVerificationEmail, actionTitle: Constants.Alerts.Actions.OK)
            self.view.layoutIfNeeded()
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
                        self.alertAccessAccount.presentSettingsActionAlert(fromController: self, title: errorMessage, message: Constants.Alerts.Messages.TouchSettings, actionTitle: Constants.Alerts.Actions.OK)
                        self.view.layoutIfNeeded()
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
            self.alertAccessAccount.presentSettingsActionAlert(fromController: self, title: Constants.Alerts.Titles.TouchID, message: Constants.Alerts.Messages.TouchSettings, actionTitle: Constants.Alerts.Actions.OK)
            self.view.layoutIfNeeded()
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
            }
            if signInButton.currentTitle == Constants.Literals.CreateAccount {
                self.createUser(email: email, password: password)
            }
        } else {
            if signInButton.currentTitle == Constants.Literals.SignIn {
                alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.SignInFailed, message: Constants.Alerts.Messages.CheckEmailPassword, actionTitle: Constants.Alerts.Actions.OK)
                self.view.layoutIfNeeded()
            } else {
                alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.CreateAccountFailed, message: Constants.Alerts.Messages.CheckEmailPassword, actionTitle: Constants.Alerts.Actions.OK)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func didTapTouch(_ sender: Any) {
        touchSignIn()
    }
    
    @IBAction func unwindToAccessAccountVC(segue: UIStoryboardSegue) {}
}
