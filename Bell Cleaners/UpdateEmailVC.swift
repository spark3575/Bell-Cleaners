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
    @IBOutlet weak var stackView: UIStackView!
    
    private var activeField: UITextField?
    private let alertUpdateEmail = PresentAlert()
    private let defaults = UserDefaults.standard
    private var enteredEmail: String?
    private var enteredPassword: String?
    private var stackViewOriginY: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newEmailField.delegate = self
        currentPasswordField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stackViewOriginY = view.frame.origin.y
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        if let enteredEmail = newEmailField.text, let enteredPassword = currentPasswordField.text, !enteredEmail.isEmpty, !enteredPassword.isEmpty {
            let user = Auth.auth().currentUser
            let credential = (EmailAuthProvider.credential(withEmail: currentEmail!, password: enteredPassword))
            user?.reauthenticate(with: credential) { error in
                if error != nil {
                    // An error happened.
                    self.alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdateEmailFailed, message: Constants.Alerts.Messages.UpdateEmailFailed, actionTitle: Constants.Alerts.Actions.OK)
                    return
                } else {
                    // User re-authenticated.
                    AuthService.instance.updateEmail(to: enteredEmail, onComplete: { (errorMessage, nil) in
                        guard errorMessage == nil else {
                            self.alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdateEmailFailed, message: errorMessage!, actionTitle: Constants.Alerts.Actions.OK)
                            return
                        }
                        self.defaults.setValue(enteredEmail, forKey: Constants.Literals.Email)
                        self.alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdateEmailSuccesful, message: Constants.Alerts.Messages.UpdateEmailSuccesful, actionTitle: Constants.Alerts.Actions.OK)
                    })
                    self.performSegue(withIdentifier: Constants.Segues.AccessAccount, sender: self)
                }
            }
        } else {
            self.alertUpdateEmail.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdateEmailFailed, message: Constants.Alerts.Messages.CheckEmailPassword, actionTitle: Constants.Alerts.Actions.OK)
        }
    }
    
    @IBAction func didTapSignOut(_ sender: SignOutButton) {
        AuthService.instance.signOut()
        performSegue(withIdentifier: Constants.Segues.BellCleaners, sender: self)
    }
}
