//
//  UpdateEmailVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 6/24/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import Firebase

class UpdateEmailVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var newEmailField: EmailField!
    @IBOutlet weak var currentPasswordField: PasswordField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    
    private var activeField: UITextField?
    private let alertUpdateEmail = PresentAlert()
    private let defaults = UserDefaults.standard
    private var enteredEmail: String?
    private var enteredPassword: String?
    private var keyboardManager: KeyboardManager?
    private let notification = NotificationCenter.default
    private var stackViewOriginY: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackViewOriginY = view.frame.origin.y
        newEmailField.delegate = self
        currentPasswordField.delegate = self
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
        if newEmailField.validate(field: newEmailField) != nil {
            textField.resignFirstResponder()
            currentPasswordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.ValidEmail, message: Constants.Alerts.Messages.VerificationEmail, actionTitle: Constants.Alerts.Actions.OK)
        }
    }
    
    private func passwordValidation(_ textField: UITextField) {
        if (textField.text?.characters.count)! >= Constants.Validations.Password.MinimumLength {
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
            alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.Password, message: Constants.Alerts.Messages.Password, actionTitle: Constants.Alerts.Actions.OK)
        }
    }
    
    @IBAction func didTapUpdate(_ sender: UpdateButton) {
        let currentEmail = defaults.string(forKey: Constants.DefaultsKeys.Email)
        if let newEmail = newEmailField.text, let currentPassword = currentPasswordField.text, !newEmail.isEmpty, !currentPassword.isEmpty {
            spinner.startAnimating()
            AuthService.instance.reauthenticate(withEmail: currentEmail!, password: currentPassword, onComplete: { (errorMessage, user) in
                self.spinner.stopAnimating()
                if let error = errorMessage, user == nil {
                    self.alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdateEmailFailed, message: error, actionTitle: Constants.Alerts.Actions.OK)
                    return
                }
                // User re-authenticated.
                self.spinner.startAnimating()
                AuthService.instance.updateEmail(to: newEmail, onComplete: { (errorMessage, user) in
                    self.spinner.stopAnimating()
                    if let error = errorMessage, user == nil {
                        self.alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdateEmailFailed, message: error, actionTitle: Constants.Alerts.Actions.OK)
                        return
                    }
                    let updatedEmail = [Constants.Literals.Email: newEmail]
                    DataService.instance.updateUser(uid: (user?.uid)!, userData: updatedEmail as [String: AnyObject])
                    self.defaults.setValue(newEmail, forKey: Constants.Literals.Email)
                    self.spinner.startAnimating()
                    AuthService.instance.reauthenticate(withEmail: newEmail, password: currentPassword, onComplete: { (errorMessage, user) in
                        self.spinner.stopAnimating()
                        if let error = errorMessage, user == nil {
                            self.alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdateEmailFailed, message: error, actionTitle: Constants.Alerts.Actions.OK)
                            self.performSegue(withIdentifier: Constants.Segues.UnwindToAccessAccountVC, sender: self)
                            return
                        }
                        self.defaults.set(false, forKey: Constants.DefaultsKeys.HasSignedInBefore)
                        self.defaults.set(false, forKey: Constants.DefaultsKeys.HasUsedTouch)
                        self.spinner.startAnimating()
                        AuthService.instance.sendVerificationEmail(onComplete: { (errorMessage, user) in
                            self.spinner.stopAnimating()
                            if let error = errorMessage, user == nil {
                                self.alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.SendVerificationEmailFailed, message: error, actionTitle: Constants.Alerts.Actions.OK)
                                return
                            }
                            let alertUpdateEmail = UIAlertController(title: Constants.Alerts.Titles.UpdateEmailSuccesful, message: Constants.Alerts.Messages.UpdateEmailSuccesful, preferredStyle: .alert)
                            alertUpdateEmail.addAction(UIAlertAction(title: Constants.Alerts.Actions.OK, style: .default, handler: { (action) in
                                self.performSegue(withIdentifier: Constants.Segues.UnwindToAccessAccountVC, sender: self)
                            }))
                            self.present(alertUpdateEmail, animated: true, completion: nil)
                        })
                    })
                })
            })
        } else {
            self.alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdateEmailFailed, message: Constants.Alerts.Messages.CheckEmailPassword, actionTitle: Constants.Alerts.Actions.OK)
        }
    }
    
    @IBAction func didTapSignOut(_ sender: SignOutButton) {
        performSegue(withIdentifier: Constants.Segues.UnwindToBellCleanersVC, sender: self)
        AuthService.instance.signOut()
    }
}
