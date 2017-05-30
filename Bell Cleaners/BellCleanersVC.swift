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
        
        navigationItem.title = bellCleanersNavBarTitle
    }
    
    private func shakeAndPlaySound() {
        bellLogoButton.shake()
        bellLogoButton.playSound(file: bellSound, ext: mp3)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Timer.scheduledTimer(withTimeInterval: delayAfterViewAppears, repeats: false) {
            [weak self] timer in
            self?.shakeAndPlaySound()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.hidesBackButton = true
        bellLogoButton.imageView?.contentMode = .scaleAspectFit
    }
    
    @IBAction func didTapAccessAccount(_ sender: AccessAccountButton) {
        guard Auth.auth().currentUser == nil else {
            performSegue(withIdentifier: myAccountSegueIdentifier, sender: nil)
            return
        }
        performSegue(withIdentifier: accessAccountSegueIdentifier, sender: nil)
    }
    
    @IBAction func didTapBell(_ sender: BellLogoButton) {
        shakeAndPlaySound()
    }
    
    @IBAction func didTapCallBell(_ sender: CallBellButton) {
        callBellButton.callBell()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = emptyLeftBarButtonItemTitle
        navigationItem.backBarButtonItem = backButton
    }
}
