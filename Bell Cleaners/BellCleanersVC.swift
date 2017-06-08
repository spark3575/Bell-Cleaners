//
//  BellCleanersVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/20/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import Firebase

class BellCleanersVC: UIViewController {    
    @IBOutlet weak var bellLogoButton: BellLogoButton!
    @IBOutlet weak var callBellButton: CallBellButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = bellCleanersLiteral
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Timer.scheduledTimer(withTimeInterval: delayAfterViewAppears, repeats: false) {
            [weak self] timer in
            self?.bellLogoButton.shakeAndPlaySound()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        bellLogoButton.imageView?.contentMode = .scaleAspectFit
    }
    
    @IBAction func didTapAccessAccount(_ sender: AccessAccountButton) {
        self.performSegue(withIdentifier: accessAccountSegue, sender: self)
    }
    
    @IBAction func didTapBell(_ sender: BellLogoButton) {
        bellLogoButton.shakeAndPlaySound()
    }
    
    @IBAction func didTapCallBell(_ sender: CallBellButton) {
        callBellButton.callBell()
    }
}
