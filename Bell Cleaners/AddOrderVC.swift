//
//  AddOrderVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 7/7/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class AddOrderVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapAddOrder(_ sender: AddOrderButton) {
        
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
