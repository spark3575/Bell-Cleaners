//
//  ProfileVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 6/12/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: EmailField!
    @IBOutlet weak var passwordField: PasswordField!
    @IBOutlet weak var firstNameField: FirstNameField!
    @IBOutlet weak var lastNameField: LastNameField!
    @IBOutlet weak var phoneNumberField: PhoneNumberField!
    @IBOutlet weak var pickupDeliverySwitch: UISwitch!
    @IBOutlet weak var addressField: AddressField!
    @IBOutlet weak var cityField: CityField!
    @IBOutlet weak var zipcodeField: ZipcodeField!
    @IBOutlet weak var textStack: UIStackView!
    @IBOutlet weak var textStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var activeField: UITextField?
    private let alertProfile = PresentAlert()
    private var currentEmail = String()
    private var currentPassword = String()
    private let defaults = UserDefaults.standard
    private var handle: AuthStateDidChangeListenerHandle?
    private var nextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        firstNameField.delegate = self
        lastNameField.delegate = self
        phoneNumberField.delegate = self
        addressField.delegate = self
        cityField.delegate = self
        zipcodeField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spinner.startAnimating()
        DataService.instance.currentUserRef.observe(.value, with: { (snapshot) in
            self.spinner.stopAnimating()
            if let user = snapshot.value as? [String : AnyObject] {
                let email = user[Constants.Literals.Email] ?? Constants.Literals.EmptyString as AnyObject
                let password = user[Constants.Literals.Password] ?? Constants.Literals.EmptyString as AnyObject
                let firstName = user[Constants.Literals.FirstName] ?? Constants.Literals.EmptyString as AnyObject
                let lastName = user[Constants.Literals.LastName] ?? Constants.Literals.EmptyString as AnyObject
                let phoneNumber = user[Constants.Literals.PhoneNumber] ?? Constants.Literals.EmptyString as AnyObject
                let pickupDelivery = user[Constants.Literals.PickupDelivery] ?? false as AnyObject
                let address = user[Constants.Literals.Address] ?? Constants.Literals.EmptyString as AnyObject
                let city = user[Constants.Literals.City] ?? Constants.Literals.EmptyString as AnyObject
                let zipcode = user[Constants.Literals.Zipcode] ?? Constants.Literals.EmptyString as AnyObject
                self.currentEmail = (email as! String)
                self.emailField.text = self.currentEmail
                self.currentPassword = (password as! String)
                self.passwordField.text = self.currentPassword
                self.firstNameField.text = (firstName as! String)
                self.lastNameField.text = (lastName as! String)
                self.phoneNumberField.text = (phoneNumber as! String)
                self.pickupDeliverySwitch.isOn = (pickupDelivery as! Bool)
                self.addressField.text = (address as! String)
                self.cityField.text = (city as! String)
                self.zipcodeField.text = (zipcode as! String)
                if self.pickupDeliverySwitch.isOn {
                    self.addressField.isHidden = false
                    self.cityField.isHidden = false
                    self.zipcodeField.isHidden = false
                }
            }
        })
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        addNextButtonToKeyboard(textField: phoneNumberField, actionTitle: Constants.Keyboards.ActionNext, action: #selector(goToNextField(currentTextField:)))
        addNextButtonToKeyboard(textField: zipcodeField, actionTitle: Constants.Keyboards.ActionDone, action: #selector(goToNextField(currentTextField:)))
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
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.textStackTopConstraint.constant = targetOffsetForTopConstraint
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: keyboardDuration!) {
            self.textStackTopConstraint.constant = Constants.Keyboards.OriginalConstraint
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func goToNextField(currentTextField: UITextField) {
        let nextFieldToBeEdited = nextFieldToEdit(activeField!)
        if pickupDeliverySwitch.isOn {
            if activeField != nextFieldToBeEdited {
                nextFieldToBeEdited.becomeFirstResponder()
            } else {
                self.view.endEditing(true)
            }
        } else {
            self.view.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextFieldToBeEdited = nextFieldToEdit(activeField!)
        switch textField.returnKeyType {
        case .next:
            textField.resignFirstResponder()
            nextFieldToBeEdited.becomeFirstResponder()
        case .done:
            textField.resignFirstResponder()
        default:
            break
        }
        return true
    }
    
    private func nextFieldToEdit(_ textField: UITextField) -> UITextField {
        _ = textField.tag
        switch textField.tag {
        case 0: nextField = passwordField
        case 1: nextField = firstNameField
        case 2: nextField = lastNameField
        case 3: nextField = phoneNumberField
        case 4: nextField = addressField
        case 5: nextField = cityField
        case 6: nextField = zipcodeField
        case 7: nextField = zipcodeField
        default: break
        }
        return nextField!
    }
    
    private func addNextButtonToKeyboard(textField: UITextField, actionTitle: String, action: Selector?) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: Constants.Keyboards.ToolbarHeight))
        toolbar.barStyle = UIBarStyle.default
        toolbar.tintColor = Constants.Colors.BellGreen
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let action: UIBarButtonItem = UIBarButtonItem(title: actionTitle, style: UIBarButtonItemStyle.done, target: self, action: action)
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(action)
        toolbar.items = items
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
    }
    
    @IBAction func didTogglePickupDelivery(_ sender: UISwitch) {
        if !pickupDeliverySwitch.isOn {
            self.addressField.isHidden = true
            self.cityField.isHidden = true
            self.zipcodeField.isHidden = true
        } else {
            self.addressField.isHidden = false
            self.cityField.isHidden = false
            self.zipcodeField.isHidden = false
        }
    }
    
    @IBAction func didTapSave(_ sender: SaveButton) {
        var userData = [Constants.Literals.Email: emailField.text as AnyObject,
                        Constants.Literals.Password: passwordField.text as AnyObject,
                        Constants.Literals.FirstName: firstNameField.text as AnyObject,
                        Constants.Literals.LastName: lastNameField.text as AnyObject,
                        Constants.Literals.PhoneNumber: phoneNumberField.text as AnyObject,
                        Constants.Literals.PickupDelivery: pickupDeliverySwitch.isOn as AnyObject,
                        Constants.Literals.Address: addressField.text as AnyObject,
                        Constants.Literals.City: cityField.text as AnyObject,
                        Constants.Literals.Zipcode: zipcodeField.text as AnyObject,
                        Constants.Literals.AbleToAccessMyAccount: defaults.bool(forKey: Constants.DefaultsKeys.AbleToAccessMyAccount) as AnyObject]
        if !pickupDeliverySwitch.isOn {
            if let email = emailField.text, email != currentEmail {
                AuthService.instance.updateEmail(to: email, onComplete: { (errorMessage, nil) in
                    if errorMessage == Constants.ErrorMessages.RequiresRecentLogin {
                        let user = Auth.auth().currentUser
                        var credential: AuthCredential
                        var enteredPassword = String()
                        credential = (EmailAuthProvider.credential(withEmail: self.currentEmail, password: enteredPassword))
                        let reAuthenticateAlert = UIAlertController(title: "Re-authentication Required", message: "Please enter your password", preferredStyle: .alert)
                        reAuthenticateAlert.addAction(UIAlertAction(title: "Re-authenticate", style: .default, handler: { action in
                            enteredPassword = (reAuthenticateAlert.textFields?.first?.text)!
                            user?.reauthenticate(with: credential) { error in
                                if error != nil {
                                    // An error happened.
                                    self.alertProfile.presentAlert(fromController: self, title: "Re-authentication Failed", message: "Please sign in again", actionTitle: Constants.Alerts.Actions.OK)
                                    self.performSegue(withIdentifier: Constants.Segues.AccessAccount, sender: self)
                                    return
                                } else {
                                    // User re-authenticated.
                                    AuthService.instance.updateEmail(to: email, onComplete: nil)
                                }
                            }
                        }))
                        reAuthenticateAlert.addTextField(configurationHandler: nil)
                        self.present(reAuthenticateAlert, animated: true, completion: nil)                        
                    } else {
                        self.alertProfile.presentAlert(fromController: self, title: "Email Update Failed", message: errorMessage!, actionTitle: Constants.Alerts.Actions.OK)
                    }
                })
            }
            if let firstName = firstNameField.text, let lastName = lastNameField.text, let phoneNumber = phoneNumberField.text, !firstName.isEmpty && !lastName.isEmpty && !phoneNumber.isEmpty {
                defaults.set(true, forKey: Constants.DefaultsKeys.AbleToAccessMyAccount)
                userData.updateValue(true as AnyObject, forKey: Constants.DefaultsKeys.AbleToAccessMyAccount)
                DataService.instance.updateUser(uid: (Auth.auth().currentUser?.uid)!, userData: userData as [String : AnyObject])
                performSegue(withIdentifier: Constants.Segues.MyAccount, sender: self)
                return
            } else {
                self.alertProfile.presentAlert(fromController: self, title: Constants.Alerts.Titles.MissingFields, message: Constants.Alerts.Messages.MissingFields, actionTitle: Constants.Alerts.Actions.OK)
            }
        }
        if pickupDeliverySwitch.isOn {
            if let email = emailField.text, let password = passwordField.text, let firstName = firstNameField.text, let lastName = lastNameField.text, let phoneNumber = phoneNumberField.text, let address = addressField.text, let city = cityField.text, let zipcode = zipcodeField.text, !email.isEmpty && !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !phoneNumber.isEmpty, !address.isEmpty, !city.isEmpty, !zipcode.isEmpty {
                defaults.set(true, forKey: Constants.DefaultsKeys.AbleToAccessMyAccount)
                defaults.set(true, forKey: Constants.DefaultsKeys.AbleToAccessPickupDelivery)
                DataService.instance.updateUser(uid: (Auth.auth().currentUser?.uid)!, userData: userData as [String : AnyObject])
                performSegue(withIdentifier: Constants.Segues.MyAccount, sender: self)
                return
            } else {
                self.alertProfile.presentAlert(fromController: self, title: Constants.Alerts.Titles.MissingFields, message: Constants.Alerts.Messages.AllRequired, actionTitle: Constants.Alerts.Actions.OK)
            }
        }
    }
    
    @IBAction func didTapSignOut(_ sender: SignOutButton) {
        DataService.instance.currentUserRef.removeAllObservers()
        AuthService.instance.signOut()
        performSegue(withIdentifier: Constants.Segues.BellCleaners, sender: self)
    }
}
