//
//  CreateAccountVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/26/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountVC: UIViewController, UITextFieldDelegate {
    
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
    
    private var activeField: UITextField?
    private var nextField: UITextField?
    private let fieldsNotFilled = PresentAlert()

    override func viewDidLoad() {
        super.viewDidLoad()        
        navigationItem.title = signInLiteral
        emailField.delegate = self
        passwordField.delegate = self
        firstNameField.delegate = self
        lastNameField.delegate = self
        phoneNumberField.delegate = self
        addressField.delegate = self
        cityField.delegate = self
        zipcodeField.delegate = self
        
        DataService.instance.currentUserRef.observe(.value, with: { (snapshot) in
            if let user = snapshot.value as? [String : AnyObject] {
                let email = user[emailLiteral] ?? emptyLiteral as AnyObject
                let password = user[passwordLiteral] ?? emptyLiteral as AnyObject
                let firstName = user[firstNameLiteral] ?? emptyLiteral as AnyObject
                let lastName = user[lastNameLiteral] ?? emptyLiteral as AnyObject
                let phoneNumber = user[phoneNumberLiteral] ?? emptyLiteral as AnyObject
                let pickupDelivery = user[pickupDeliveryLiteral] ?? false as AnyObject
                let address = user[addressLiteral] ?? emptyLiteral as AnyObject
                let city = user[cityLiteral] ?? emptyLiteral as AnyObject
                let zipcode = user[zipcodeLiteral] ?? emptyLiteral as AnyObject
                self.emailField.text = (email as! String)
                self.passwordField.text = (password as! String)
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
        addNextButtonToKeyboard(textField: phoneNumberField, actionTitle: "Next", action: #selector(goToNextField(currentTextField:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        let targetY = view.frame.size.height - (keyboardFrame?.height)! - 8 - (activeField?.frame.size.height)!
        let textFieldY = textStack.frame.origin.y + (activeField?.frame.origin.y)!
        let difference = targetY - textFieldY
        let targetOffsetForTopConstraint = textStackTopConstraint.constant + difference
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.textStackTopConstraint.constant = targetOffsetForTopConstraint
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: keyboardDuration!) {
            self.textStackTopConstraint.constant = 64
            self.view.layoutIfNeeded()
        }
    }
    
    func addNextButtonToKeyboard(textField: UITextField, actionTitle: String, action: Selector?) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        toolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let action: UIBarButtonItem = UIBarButtonItem(title: actionTitle, style: UIBarButtonItemStyle.done, target: self, action: action)
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(action)
        toolbar.items = items
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
    }
    
    func nextFieldToEdit(_ textField: UITextField) -> UITextField {
        _ = textField.tag
        switch textField.tag {
        case 0: nextField = passwordField
        case 1: nextField = firstNameField
        case 2: nextField = lastNameField
        case 3: nextField = phoneNumberField
        case 4: nextField = addressField
        case 5: nextField = cityField
        case 6: nextField = zipcodeField
        default: nextField = emailField
        }
        return nextField!
    }
    
    func goToNextField(currentTextField: UITextField) {
        if pickupDeliverySwitch.isOn {
            nextField = nextFieldToEdit(activeField!)
            nextField?.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nextField = nextFieldToEdit(activeField!)
        switch textField.returnKeyType {
        case .next:
            textField.resignFirstResponder()
            nextField?.becomeFirstResponder()
        case .done:
            textField.resignFirstResponder()
        default:
            break
        }
        return true
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
        let userData = [emailLiteral: emailField.text as AnyObject,
                        passwordLiteral: passwordField.text as AnyObject,
                        firstNameLiteral: firstNameField.text as AnyObject,
                        lastNameLiteral: lastNameField.text as AnyObject,
                        phoneNumberLiteral: phoneNumberField.text as AnyObject,
                        pickupDeliveryLiteral: pickupDeliverySwitch.isOn as AnyObject,
                        addressLiteral: addressField.text as AnyObject,
                        cityLiteral: cityField.text as AnyObject,
                        zipcodeLiteral: zipcodeField.text as AnyObject]
        DataService.instance.updateUser(uid: (Auth.auth().currentUser?.uid)!, userData: userData as [String : AnyObject])
        DataService.instance.currentUserRef.observe(.value, with: { (snapshot) in
            print(snapshot.childrenCount)
            var filledCount = 0
            if let user = snapshot.value as? [String : AnyObject] {
                for eachValue in user {
                    if (eachValue.value as! String != emptyLiteral) {
                        filledCount += 1
                    }
                }
            }
            print(filledCount)
            if filledCount < Int(snapshot.childrenCount) {
                self.fieldsNotFilled.presentAlert(fromController: self, title: fieldsNotFilledTitle, message: fieldsNotFilledMessage, actionTitle: okAlertActionTitle)
            } else {
                AuthService.profileFull = true
                self.performSegue(withIdentifier: myAccountSegue, sender: self)
            }
        })
    }
    
    @IBAction func didTapSignOut(_ sender: SignOutButton) {
        AuthService.instance.signOut()
        performSegue(withIdentifier: bellCleanersSegue, sender: self)
    }
}
