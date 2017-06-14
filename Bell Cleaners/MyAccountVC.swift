//
//  MyAccountVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/28/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import Firebase

class MyAccountVC: UIViewController {
    
    @IBOutlet weak var callBellButton: CallBellButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapOrders(_ sender: OrdersButton) {
        
    }
    
    @IBAction func didTapSettings(_ sender: SettingsButton) {
        guard let settingsURL = Constants.URLs.Settings else { return }
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
    }
    
    @IBAction func didTapSupport(_ sender: SupportButton) {
        
    }
    
    @IBAction func didTapCallBell(_ sender: CallBellButton) {
        callBellButton.callBell()
    }

    @IBAction func didTapSignOut(_ sender: SignOutButton) {
        AuthService.instance.signOut()
        performSegue(withIdentifier: Constants.Segues.BellCleaners, sender: self)
    }
}
