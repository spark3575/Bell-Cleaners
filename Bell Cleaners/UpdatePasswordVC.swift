//
//  UpdatePasswordVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 6/24/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import Firebase

class UpdatePasswordVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var currentPasswordField: CurrentPasswordField!
    @IBOutlet weak var newPasswordField: NewPasswordField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    
    private var activeField: UITextField?
    private let alertUpdatePassword = PresentAlert()
    private var currentPassword: String?
    private let defaults = UserDefaults.standard
    private var keyboardManager: KeyboardManager?
    private var newPassword: String?
    private let notification = NotificationCenter.default
    private var stackViewOriginY: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackViewOriginY = view.frame.origin.y
        currentPasswordField.delegate = self
        newPasswordField.delegate = self
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
        notification.removeObserver(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.returnKeyType {
        case .next:
            passwordValidation(textField)
            newPasswordField.becomeFirstResponder()
        case .done:
            passwordValidation(textField)
        default:
            break
        }
        return true
    }
    
    private func passwordValidation(_ textField: UITextField) {
        if (textField.text?.characters.count)! >= Constants.Validations.Password.MinimumLength {
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
            alertUpdatePassword.presentAlert(fromController: self, title: Constants.Alerts.Titles.Password, message: Constants.Alerts.Messages.Password, actionTitle: Constants.Alerts.Actions.OK)
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func didTapUpdate(_ sender: UpdateButton) {
        let currentEmail = defaults.string(forKey: Constants.DefaultsKeys.Email)
        if let currentPassword = currentPasswordField.text, let newPassword = newPasswordField.text, !currentPassword.isEmpty, !newPassword.isEmpty {
            spinner.startAnimating()
            AuthService.instance.reauthenticate(withEmail: currentEmail!, password: currentPassword, onComplete: { (errorMessage, user) in
                self.spinner.stopAnimating()
                guard errorMessage == nil, user != nil else {
                    self.alertUpdatePassword.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdatePasswordFailed, message: errorMessage!, actionTitle: Constants.Alerts.Actions.OK)
                    self.view.layoutIfNeeded()
                    return
                }
                // User re-authenticated.
                self.spinner.startAnimating()
                AuthService.instance.updatePassword(to: newPassword, onComplete: { (errorMessage, user) in
                    self.spinner.stopAnimating()
                    guard errorMessage == nil, user != nil else {
                        self.alertUpdatePassword.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdatePasswordFailed, message: errorMessage!, actionTitle: Constants.Alerts.Actions.OK)
                        self.view.layoutIfNeeded()
                        return
                    }
                    self.defaults.set(false, forKey: Constants.DefaultsKeys.HasSignedInBefore)
                    self.defaults.set(false, forKey: Constants.DefaultsKeys.HasUsedTouch)
                    let alertUpdatePassword = UIAlertController(title: Constants.Alerts.Titles.UpdatePasswordSuccesful, message: Constants.Alerts.Messages.UpdatePasswordSuccesful, preferredStyle: .alert)
                    alertUpdatePassword.addAction(UIAlertAction(title: Constants.Alerts.Actions.OK, style: .default, handler: { (action) in
                        self.performSegue(withIdentifier: Constants.Segues.UnwindToAccessAccountVC, sender: self)
                    }))
                    self.notification.removeObserver(self)
                    self.present(alertUpdatePassword, animated: true, completion: nil)
                })
            })
        } else {
            self.alertUpdatePassword.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdatePasswordFailed, message: Constants.Alerts.Messages.UpdatePasswordFailed, actionTitle: Constants.Alerts.Actions.OK)
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func didTapSignOut(_ sender: SignOutButton) {
        performSegue(withIdentifier: Constants.Segues.UnwindToBellCleanersVC, sender: self)
        AuthService.instance.signOut()
    }
}
