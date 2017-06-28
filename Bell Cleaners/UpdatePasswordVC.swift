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
    @IBOutlet weak var stackView: UIStackView!
    
    private var activeField: UITextField?
    private let alertUpdatePassword = PresentAlert()
    private var currentPassword: String?
    private let defaults = UserDefaults.standard
    private var handle: AuthStateDidChangeListenerHandle?
    private var newPassword: String?
    private var stackViewOriginY: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPasswordField.delegate = self
        newPasswordField.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stackViewOriginY = view.frame.origin.y
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        // [START auth_listener]
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        Auth.auth().removeStateDidChangeListener(handle!)
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
        case .next, .done:
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
        }
    }
    
    @IBAction func didTapUpdate(_ sender: UpdateButton) {
        let currentEmail = defaults.string(forKey: Constants.DefaultsKeys.Email)
        if let currentPassword = currentPasswordField.text, let newPassword = newPasswordField.text, !currentPassword.isEmpty, !newPassword.isEmpty {
            AuthService.instance.reauthenticate(withEmail: currentEmail!, password: currentPassword, onComplete: { (errorMessage, user) in
                guard errorMessage == nil else {
                    self.alertUpdatePassword.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdatePasswordFailed, message: errorMessage!, actionTitle: Constants.Alerts.Actions.OK)
                    self.performSegue(withIdentifier: Constants.Segues.UnwindToAccessAccountVC, sender: self)
                    return
                }
                // User re-authenticated.
                AuthService.instance.updatePassword(to: newPassword, onComplete: { (errorMessage, nil) in
                    guard errorMessage == nil else {
                        self.alertUpdatePassword.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdatePasswordFailed, message: errorMessage!, actionTitle: Constants.Alerts.Actions.OK)
                        return
                    }
                })
                if let user = Auth.auth().currentUser {
                    let updatedPassword = [Constants.Literals.Password: newPassword]
                    DataService.instance.updateUser(uid: user.uid, userData: updatedPassword as [String: AnyObject])
                }
            })
            let alertUpdatePassword = UIAlertController(title: Constants.Alerts.Titles.UpdatePasswordSuccesful, message: Constants.Alerts.Messages.UpdatePasswordSuccesful, preferredStyle: .alert)
            alertUpdatePassword.addAction(UIAlertAction(title: Constants.Alerts.Actions.OK, style: .default, handler: { action in
                self.performSegue(withIdentifier: Constants.Segues.UnwindToAccessAccountVC, sender: self)
            }))
            self.present(alertUpdatePassword, animated: true, completion: nil)
        } else {
            self.alertUpdatePassword.presentAlert(fromController: self, title: Constants.Alerts.Titles.UpdatePasswordFailed, message: Constants.Alerts.Messages.UpdatePasswordFailed, actionTitle: Constants.Alerts.Actions.OK)
        }
    }
    
    @IBAction func didTapSignOut(_ sender: SignOutButton) {
        AuthService.instance.signOut()
        performSegue(withIdentifier: Constants.Segues.UnwindToBellCleanersVC, sender: self)
    }
}
