//
//  AdminVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 6/15/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import Firebase

class AdminVC: UIViewController {
    
    @IBAction func didTapSignOut(_ sender: SignOutButton) {
        AuthService.instance.signOut(signedOut: { (signedOut) in
            if signedOut {
                self.performSegue(withIdentifier: Constants.Segues.UnwindToBellCleanersVC, sender: self)
                return
            }
        })
    }
}
