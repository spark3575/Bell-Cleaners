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
    private let notification = NotificationCenter.default
    private var stackViewOriginY: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackViewOriginY = view.frame.origin.y
        newEmailField.delegate = self
        currentPasswordField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        notification.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
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
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        let targetY = view.frame.size.height - (keyboardFrame?.height)! - Constants.Keyboards.SpaceToText - (activeField?.frame.size.height)!
        let textFieldY = stackView.frame.origin.y + (activeField?.frame.origin.y)!
        let differenceY = targetY - textFieldY
        let targetOffsetY = stackView.frame.origin.y + differenceY
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: Constants.Animations.Keyboard.DurationShow, animations: {
            self.stackView.frame.origin.y = targetOffsetY
            self.view.layoutIfNeeded()
        })
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
            self.view.layoutIfNeeded()
        }
    }
    
    private func passwordValidation(_ textField: UITextField) {
        if (textField.text?.characters.count)! >= Constants.Validations.Password.MinimumLength {
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
            alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.Password, message: Constants.Alerts.Messages.Password, actionTitle: Constants.Alerts.Actions.OK)
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func didTapUpdate(_ sender: UpdateButton) {
        let currentEmail = defaults.string(forKey: Constants.DefaultsKeys.Email)
        if let newEmail = newEmailField.text, let currentPassword = currentPasswordField.text, !newEmail.isEmpty, !currentPassword.isEmpty {
            spinner.startAnimating()
            AuthService.instance.reauthenticate(withEmail: currentEmail!, password: currentPassword, onComplete: { (errorMessage, user) in
                self.spinner.stopAnimating()
                guard errorMessage == nil else {
                    self.alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdateEmailFailed, message: errorMessage!, actionTitle: Constants.Alerts.Actions.OK)
                    self.view.layoutIfNeeded()
                    return
                }
                // User re-authenticated.
                self.spinner.startAnimating()
                AuthService.instance.updateEmail(to: newEmail, onComplete: { (errorMessage, nil) in
                    self.spinner.stopAnimating()
                    guard errorMessage == nil else {
                        self.alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdateEmailFailed, message: errorMessage!, actionTitle: Constants.Alerts.Actions.OK)
                        self.view.layoutIfNeeded()
                        return
                    }
                })
                if let user = Auth.auth().currentUser {
                    let updatedEmail = [Constants.Literals.Email: newEmail]
                    DataService.instance.updateUser(uid: user.uid, userData: updatedEmail as [String: AnyObject])
                }
                self.defaults.setValue(newEmail, forKey: Constants.Literals.Email)
                Timer.scheduledTimer(withTimeInterval: Constants.TimerIntervals.FirebaseDelay, repeats: false) { timer in
                    self.spinner.startAnimating()
                    AuthService.instance.reauthenticate(withEmail: newEmail, password: currentPassword, onComplete: { (errorMessage, user) in
                        self.spinner.stopAnimating()
                        guard errorMessage == nil else {
                            self.alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdateEmailFailed, message: errorMessage!, actionTitle: Constants.Alerts.Actions.OK)
                            self.notification.removeObserver(self)
                            self.performSegue(withIdentifier: Constants.Segues.UnwindToAccessAccountVC, sender: self)
                            return
                        }
                        Timer.scheduledTimer(withTimeInterval: Constants.TimerIntervals.FirebaseDelay, repeats: false) { timer in
                            if Auth.auth().currentUser != nil {
                                AuthService.instance.sendVerificationEmail()
                            }
                        }
                        self.defaults.set(false, forKey: Constants.DefaultsKeys.HasSignedInBefore)
                        self.defaults.set(false, forKey: Constants.DefaultsKeys.HasUsedTouch)
                        let alertUpdateEmail = UIAlertController(title: Constants.Alerts.Titles.UpdateEmailSuccesful, message: Constants.Alerts.Messages.UpdateEmailSuccesful, preferredStyle: .alert)
                        alertUpdateEmail.addAction(UIAlertAction(title: Constants.Alerts.Actions.OK, style: .default, handler: { action in                            
                            self.performSegue(withIdentifier: Constants.Segues.UnwindToAccessAccountVC, sender: self)
                        }))
                        self.notification.removeObserver(self)
                        self.present(alertUpdateEmail, animated: true, completion: nil)
                    })
                }
            })
        } else {
            self.alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdateEmailFailed, message: Constants.Alerts.Messages.CheckEmailPassword, actionTitle: Constants.Alerts.Actions.OK)
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func didTapSignOut(_ sender: SignOutButton) {
        notification.removeObserver(self)
        performSegue(withIdentifier: Constants.Segues.UnwindToBellCleanersVC, sender: self)
        Timer.scheduledTimer(withTimeInterval: Constants.TimerIntervals.FirebaseDelay, repeats: false) {
            timer in if Auth.auth().currentUser != nil {
                AuthService.instance.signOut()
            }
        }
    }
}
