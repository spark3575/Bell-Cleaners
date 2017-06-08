//
//  CreateAccountVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/26/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountVC: UIViewController {    
    @IBOutlet weak var emailField: EmailField!
    @IBOutlet weak var passwordField: PasswordField!
    @IBOutlet weak var firstNameField: FirstNameField!
    @IBOutlet weak var lastNameField: LastNameField!
    @IBOutlet weak var phoneNumberField: PhoneNumberField!
    @IBOutlet weak var addressField: AddressField!
    @IBOutlet weak var cityField: CityField!
    @IBOutlet weak var zipcodeField: ZipcodeField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = signInLiteral
        
        DataService.instance.currentUserRef.observe(.value, with: { (snapshot) in
            if let user = snapshot.value as? [String : AnyObject] {
                let email = user[emailLiteral] ?? emptyLiteral as AnyObject
                let password = user[passwordLiteral] ?? emptyLiteral as AnyObject
                let firstName = user[firstNameLiteral] ?? emptyLiteral as AnyObject
                let lastName = user[lastNameLiteral] ?? emptyLiteral as AnyObject
                let phoneNumber = user[phoneNumberLiteral] ?? emptyLiteral as AnyObject
                let address = user[addressLiteral] ?? emptyLiteral as AnyObject
                let city = user[cityLiteral] ?? emptyLiteral as AnyObject
                let zipcode = user[zipcodeLiteral] ?? emptyLiteral as AnyObject
                self.emailField.text = (email as! String)
                self.passwordField.text = (password as! String)
                self.firstNameField.text = (firstName as! String)
                self.lastNameField.text = (lastName as! String)
                self.phoneNumberField.text = (phoneNumber as! String)
                self.addressField.text = (address as! String)
                self.cityField.text = (city as! String)
                self.zipcodeField.text = (zipcode as! String)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.hidesBackButton = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private let fieldsNotFilled = PresentAlert()
    
    @IBAction func didTapSave(_ sender: SaveButton) {
        let userData = [emailLiteral: emailField.text as AnyObject,
                        passwordLiteral: passwordField.text as AnyObject,
                        firstNameLiteral: firstNameField.text as AnyObject,
                        lastNameLiteral: lastNameField.text as AnyObject,
                        phoneNumberLiteral: phoneNumberField.text as AnyObject,
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
