//
//  BellCleanersVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/20/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class BellCleanersVC: UIViewController {
    
    @IBOutlet weak var bellLogoButton: BellLogoButton!
    @IBOutlet weak var callBellButton: CallBellButton!
    
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
        bellLogoButton.imageView?.contentMode = .scaleAspectFit
    }
    
    @IBAction func didTapBell(_ sender: BellLogoButton) {
        shakeAndPlaySound()
    }
    
    @IBAction func didTapCallBell(_ sender: CallBellButton) {
        callBellButton.callBell()
    }
}
