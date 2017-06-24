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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    
    private var activeField: UITextField?
    private let alertProfile = PresentAlert()
    private var currentEmail = String()
    private var currentPassword = String()
    private var enteredEmailField = UITextField()
    private var enteredPasswordField = UITextField()
    private let defaults = UserDefaults.standard
    private var handle: AuthStateDidChangeListenerHandle?
    private var nextField: UITextField?
    private var stackViewOriginY: CGFloat?
    
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
        stackViewOriginY = view.frame.origin.y
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
        if activeField == emailField {
            NotificationCenter.default.removeObserver(self)
            performSegue(withIdentifier: Constants.Segues.UpdateEmail, sender: self)
        }
        if activeField == passwordField {
            NotificationCenter.default.removeObserver(self)
            performSegue(withIdentifier: Constants.Segues.UpdatePassword, sender: self)
        }
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
        UIView.animate(withDuration: Constants.Animations.Keyboard.DurationShow, animations: {
            self.stackView.frame.origin.y = targetOffsetY
            self.view.layoutIfNeeded()
        })
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
            UIView.animate(withDuration: Constants.Animations.Switch.Duration, animations: {
                self.addressField.isHidden = true
                self.cityField.isHidden = true
                self.zipcodeField.isHidden = true
            })
        } else {
            UIView.animate(withDuration: Constants.Animations.Switch.Duration, animations: {
                self.addressField.isHidden = false
                self.cityField.isHidden = false
                self.zipcodeField.isHidden = false
            })
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
            if let firstName = firstNameField.text, let lastName = lastNameField.text, let phoneNumber = phoneNumberField.text, let address = addressField.text, let city = cityField.text, let zipcode = zipcodeField.text, !firstName.isEmpty, !lastName.isEmpty, !phoneNumber.isEmpty, !address.isEmpty, !city.isEmpty, !zipcode.isEmpty {
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
