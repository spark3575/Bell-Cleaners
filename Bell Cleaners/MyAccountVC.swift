//
//  MyAccountVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/28/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import FirebaseAuth

class MyAccountVC: UIViewController {
    
    @IBOutlet weak var callBellButton: CallBellButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = myAccountLiteral
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func didTapOrders(_ sender: OrdersButton) {
        
    }
    
    @IBAction func didTapProfile(_ sender: ProfileButton) {
        
    }
    
    @IBAction func didTapSettings(_ sender: SettingsButton) {
        guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
    }
    
    @IBAction func didTapSupport(_ sender: SupportButton) {
        
    }
    
    @IBAction func didTapCallBell(_ sender: CallBellButton) {
        callBellButton.callBell()
    }

    @IBAction func didTapSignOut(_ sender: SignOutButton) {
        DataService.instance.currentUserRef.removeAllObservers()
        AuthService.instance.signOut()
        performSegue(withIdentifier: bellCleanersSegue, sender: self)
    }
}
