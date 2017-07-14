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
    
    @IBOutlet weak var addressField: AddressField!
    @IBOutlet weak var cityField: CityField!
    @IBOutlet weak var emailField: EmailField!
    @IBOutlet weak var firstNameField: FirstNameField!
    @IBOutlet weak var lastNameField: LastNameField!
    @IBOutlet weak var passwordField: PasswordField!
    @IBOutlet weak var phoneNumberField: PhoneNumberField!
    @IBOutlet weak var pickupDeliverySwitch: UISwitch!
    @IBOutlet weak var zipcodeField: ZipcodeField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    
    private var activeField: UITextField?
    private let alertProfile = PresentAlert()
    private var currentCustomer: Customer?
    private var currentEmail = String()
    private var currentPassword = String()
    private let currentUserRef = DataService.instance.currentUserRef
    private var databaseHandle: DatabaseHandle!
    private var enteredEmailField = UITextField()
    private var enteredPasswordField = UITextField()
    private let defaults = UserDefaults.standard
    private var keyboardManager: KeyboardManager?
    private var nextField: UITextField?
    private let notification = NotificationCenter.default
    private var stackViewOriginY: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackViewOriginY = view.frame.origin.y
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
        self.spinner.startAnimating()
        DataService.instance.cutomersRef.queryOrdered(byChild: Constants.Literals.UserID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.spinner.stopAnimating()
            let user = Auth.auth().currentUser
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var customers = [Customer]()
                for snap in snapshot {
                    if let customerDict = snap.value as? DataService.StringAnyobjectDict {
                        let key = snap.key
                        let customer = Customer(ID: key, customerData: customerDict)
                        customers.append(customer)
                        if customer.userID == user?.uid {
                            self.currentCustomer = customer
                        }
                    }
                }
            }
            if let currentCustomer = self.currentCustomer {
                self.currentEmail = currentCustomer.email
                self.emailField.text = self.currentEmail
                self.passwordField.formatWithSecureText(password: self.currentPassword, email: self.currentEmail, formattedTextField: self.passwordField)
                self.firstNameField.text = currentCustomer.firstName
                self.lastNameField.text = currentCustomer.lastName
                self.phoneNumberField.text = currentCustomer.phoneNumber
                self.pickupDeliverySwitch.isOn = currentCustomer.pickupDelivery
                if self.pickupDeliverySwitch.isOn {
                    self.addressField.isHidden = false
                    self.cityField.isHidden = false
                    self.zipcodeField.isHidden = false
                    self.addressField.text = currentCustomer.address
                    self.cityField.text = currentCustomer.city
                    self.zipcodeField.text = currentCustomer.zipcode
                } else {
                    self.addressField.isHidden = true
                    self.cityField.isHidden = true
                    self.zipcodeField.isHidden = true
                }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notification.removeObserver(self)        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentUserRef.removeAllObservers()
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
        if textField != emailField, textField != passwordField {
            activeField = textField
            keyboardManager = KeyboardManager(observer: self, viewOfVC: [view], stackViewToMove: [stackView], textFieldToMove: [activeField!], notifyFromObject: nil)
            keyboardManager?.viewMoveWhenKeyboardWillShow()
            addNextButtonToKeyboard(textField: phoneNumberField, actionTitle: Constants.Keyboards.ActionNext, action: #selector(goToNextField))
            addNextButtonToKeyboard(textField: zipcodeField, actionTitle: Constants.Keyboards.ActionDone, action: #selector(goToNextField))
        }
        if textField == emailField {
            notification.removeObserver(self)
            performSegue(withIdentifier: Constants.Segues.UpdateEmailVC, sender: self)
        }
        if textField == passwordField {
            notification.removeObserver(self)
            performSegue(withIdentifier: Constants.Segues.UpdatePasswordVC, sender: self)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    @objc func goToNextField() {
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
        toolbar.tintColor = Constants.Colors.GreenMedium
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
        var userData = [Constants.Literals.FirstName: firstNameField.text as AnyObject,
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
                DataService.instance.updateDBUser(uid: (Auth.auth().currentUser?.uid)!, userData: userData as [String : AnyObject])
                spinner.startAnimating()
                AuthService.instance.createProfileChangeRequest(name: firstName, onComplete: { (errorMessage, user) in
                    self.spinner.stopAnimating()
                    if let error = errorMessage, user == nil {
                        self.alertProfile.presentAlert(fromController: self, title: Constants.Alerts.Titles.SetDisplayNameFailed, message: error, actionTitle: Constants.Alerts.Actions.OK)
                        return
                    }
                    self.performSegue(withIdentifier: Constants.Segues.MyAccountVC, sender: self)
                })
            } else {
                self.alertProfile.presentAlert(fromController: self, title: Constants.Alerts.Titles.MissingFields, message: Constants.Alerts.Messages.MissingFields, actionTitle: Constants.Alerts.Actions.OK)
            }
        }
        if pickupDeliverySwitch.isOn {
            if let firstName = firstNameField.text, let lastName = lastNameField.text, let phoneNumber = phoneNumberField.text, let address = addressField.text, let city = cityField.text, let zipcode = zipcodeField.text, !firstName.isEmpty, !lastName.isEmpty, !phoneNumber.isEmpty, !address.isEmpty, !city.isEmpty, !zipcode.isEmpty {
                defaults.set(true, forKey: Constants.DefaultsKeys.AbleToAccessMyAccount)
                defaults.set(true, forKey: Constants.DefaultsKeys.AbleToAccessPickupDelivery)
                DataService.instance.updateDBUser(uid: (Auth.auth().currentUser?.uid)!, userData: userData as [String : AnyObject])
                spinner.startAnimating()
                AuthService.instance.createProfileChangeRequest(name: firstName, onComplete: { (errorMessage, user) in
                    self.spinner.stopAnimating()
                    if let error = errorMessage, user == nil {
                        self.alertProfile.presentAlert(fromController: self, title: Constants.Alerts.Titles.SetDisplayNameFailed, message: error, actionTitle: Constants.Alerts.Actions.OK)
                        return
                    }
                    self.performSegue(withIdentifier: Constants.Segues.MyAccountVC, sender: self)
                })
            } else {
                self.alertProfile.presentAlert(fromController: self, title: Constants.Alerts.Titles.MissingFields, message: Constants.Alerts.Messages.AllRequired, actionTitle: Constants.Alerts.Actions.OK)
            }
        }
    }
    
    @IBAction func didTapSignOut(_ sender: SignOutButton) {
        AuthService.instance.signOut(signedOut: { (signedOut) in
            if signedOut {
                self.performSegue(withIdentifier: Constants.Segues.UnwindToBellCleanersVC, sender: self)
                return
            }
        })
    }
}
