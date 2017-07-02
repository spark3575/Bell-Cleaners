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
        performSegue(withIdentifier: Constants.Segues.UnwindToBellCleanersVC, sender: self)
        Timer.scheduledTimer(withTimeInterval: Constants.TimerIntervals.FirebaseDelay, repeats: false) { (timer) in
            if Auth.auth().currentUser != nil {
                AuthService.instance.signOut()
            }
        }
    }
}
