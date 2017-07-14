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
    private var currentCustomer: Customer?
    private let defaults = UserDefaults.standard
    private var keyboardManager: KeyboardManager?
    private let notification = NotificationCenter.default
    private var passwordItems: [KeychainPasswordItem] = []
    private var securedTextEmail: String?
    private var stackViewOriginY: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        stackViewOriginY = view.frame.origin.y
        if (defaults.bool(forKey: Constants.DefaultsKeys.HasSignedInBefore)) {
            if let email = defaults.string(forKey: Constants.DefaultsKeys.Email) {
                emailField.formatWithSecureText(email: email, formattedTextField: emailField)
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
        }
    }
    
    private func passwordValidation(_ textField: UITextField) {
        if (textField.text?.characters.count)! >= Constants.Validations.Password.MinimumLength {
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
            alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.Password, message: Constants.Alerts.Messages.Password, actionTitle: Constants.Alerts.Actions.OK)
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
                return
            }
            if errorMessage == Constants.ErrorMessages.InvalidPassword {
                alertSignInFailed = UIAlertController(title: Constants.Alerts.Titles.IncorrectPassword, message: Constants.Alerts.Messages.IncorrectPassword, preferredStyle: .alert)
                alertSignInFailed.addAction(UIAlertAction(title: Constants.Alerts.Actions.SendResetPasswordEmail, style: .default, handler: { (action) in
                    self.spinner.startAnimating()
                    AuthService.instance.sendPasswordReset(withEmail: email, onComplete: { (errorMessage, user) in
                        self.spinner.stopAnimating()
                        if let error = errorMessage, user == nil {
                            self.alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.SendResetPasswordEmailFailed, message: error, actionTitle: Constants.Alerts.Actions.OK)
                            return
                        }
                        self.alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.ResetPasswordEmailSent, message: Constants.Alerts.Messages.ResetPasswordEmailSent, actionTitle: Constants.Alerts.Actions.OK)
                        return
                    })
                }))
                alertSignInFailed.addAction(UIAlertAction(title: Constants.Alerts.Actions.Cancel, style: .default, handler: nil))
                self.present(alertSignInFailed, animated: true, completion: nil)
                return
            }
            if let error = errorMessage {
                self.alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.SignInFailed, message: error, actionTitle: Constants.Alerts.Actions.OK)
                return
            }
            self.saveLogin(email: email, password: password)
            if let user = Auth.auth().currentUser , user.isEmailVerified {
                self.spinner.startAnimating()
                DataService.instance.cutomersRef.queryOrdered(byChild: Constants.Literals.UserID).observeSingleEvent(of: .value, with: { (snapshot) in
                    self.spinner.stopAnimating()
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        var customerAvailable = false
                        var customers = [Customer]()
                        var userIDs = [String]()
                        for snap in snapshot {
                            if let customerDict = snap.value as? DataService.StringAnyobjectDict {
                                let key = snap.key
                                let customer = Customer(ID: key, customerData: customerDict)
                                customers.append(customer)
                                userIDs.append(customer.userID)
                                if !customerAvailable, customer.userID == user.uid {
                                    self.currentCustomer = customer
                                    customerAvailable = true
                                }
                            }
                        }
                        if !customerAvailable, !userIDs.contains(user.uid) {
                            let customerData = [Constants.Literals.AbleToAccessMyAccount: false,
                                                Constants.Literals.Address: Constants.Literals.EmptyString,
                                                Constants.Literals.City: Constants.Literals.EmptyString,
                                                Constants.Literals.Email: email,
                                                Constants.Literals.FirstName: Constants.Literals.EmptyString,
                                                Constants.Literals.LastName: Constants.Literals.EmptyString,
                                                Constants.Literals.PhoneNumber: Constants.Literals.EmptyString,
                                                Constants.Literals.PickupDelivery: false,
                                                Constants.Literals.UserID: user.uid,
                                                Constants.Literals.Zipcode: Constants.Literals.EmptyString] as DataService.StringAnyobjectDict
                            DataService.instance.createCustomer(userData: customerData as DataService.StringAnyobjectDict)
                            self.currentCustomer = Customer(customerData: customerData)
                        }
                    }
                    let ableToAccess = self.currentCustomer?.ableToAccessMyAccount ?? false
                    let ableToAccessMyAccount = ableToAccess
                    self.defaults.set(ableToAccessMyAccount, forKey: Constants.DefaultsKeys.AbleToAccessMyAccount)
                    let userEmail = self.currentCustomer?.email
                    let customerEmail = userEmail
                    if customerEmail == Constants.Literals.AdminEmail {
                        self.performSegue(withIdentifier: Constants.Segues.AdminVC, sender: self)
                        return
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
                        self.spinner.startAnimating()
                        AuthService.instance.sendVerificationEmail(onComplete: { (errorMessage, user) in
                            self.spinner.stopAnimating()
                            if let error = errorMessage, user != nil {
                                self.alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.SendVerificationEmailFailed, message: error, actionTitle: Constants.Alerts.Actions.OK)
                                return
                            }
                            self.alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.VerificationEmailSent, message: Constants.Alerts.Messages.VerificationEmailSent, actionTitle: Constants.Alerts.Actions.OK)
                        })
                    }))
                }
                alertEmailVerification.addAction(UIAlertAction(title: Constants.Alerts.Actions.OK, style: .default, handler: nil))
                self.present(alertEmailVerification, animated: true, completion: nil)
            }
        })
    }
    
    private func createUser(email: String, password: String) {
        spinner.startAnimating()
        AuthService.instance.createUser(withEmail: email, password: password, onComplete: { (errorMessage, user) in
            self.spinner.stopAnimating()
            if let error = errorMessage, user == nil {
                self.alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.CreateAccountFailed, message: error, actionTitle: Constants.Alerts.Actions.OK)
                return
            }
            self.signInButton.setTitle(Constants.Literals.SignIn, for: .normal)
            self.textViewStack.isHidden = true
            self.spinner.startAnimating()
            AuthService.instance.sendVerificationEmail(onComplete: { (errorMessage, user) in
                self.spinner.stopAnimating()
                if let error = errorMessage, user == nil {
                    self.alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.SendVerificationEmailFailed, message: error, actionTitle: Constants.Alerts.Actions.OK)
                    return
                }
                self.saveLogin(email: email, password: password)
                self.alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.CreateAccountSuccesful, message: Constants.Alerts.Messages.CheckVerificationEmail, actionTitle: Constants.Alerts.Actions.OK)
            })
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
            } else {
                alertAccessAccount.presentAlert(fromController: self, title: Constants.Alerts.Titles.CreateAccountFailed, message: Constants.Alerts.Messages.CheckEmailPassword, actionTitle: Constants.Alerts.Actions.OK)
            }
        }
    }
    
    @IBAction func didTapTouch(_ sender: Any) {
        touchSignIn()
    }
    
    @IBAction func unwindToAccessAccountVC(segue: UIStoryboardSegue) {}
}
