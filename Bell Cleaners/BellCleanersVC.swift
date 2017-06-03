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
    
    private func shakeAndPlaySound() {
        bellLogoButton.shake()
        bellLogoButton.playSound(file: bellSound, ext: mp3)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        Timer.scheduledTimer(withTimeInterval: delayAfterViewAppears, repeats: false) {
//            [weak self] timer in
//            self?.shakeAndPlaySound()
//        }
    }
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.hidesBackButton = true
        bellLogoButton.imageView?.contentMode = .scaleAspectFit
    }
    
    @IBAction func didTapAccessAccount(_ sender: AccessAccountButton) {
        if Auth.auth().currentUser != nil && AuthService.profileFull == false {
            self.performSegue(withIdentifier: signUpSegue, sender: self)
            return
        }
        if Auth.auth().currentUser != nil && AuthService.profileFull == true {
            self.performSegue(withIdentifier: myAccountSegue, sender: self)
            return
        }
        self.performSegue(withIdentifier: accessAccountSegue, sender: self)
    }
    
    @IBAction func didTapBell(_ sender: BellLogoButton) {
        shakeAndPlaySound()
    }
    
    @IBAction func didTapCallBell(_ sender: CallBellButton) {
        callBellButton.callBell()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = emptyLiteral
        navigationItem.backBarButtonItem = backButton
    }
}
