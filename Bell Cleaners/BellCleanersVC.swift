//
//  BellCleanersVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/20/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class BellCleanersVC: UIViewController {

    @IBOutlet weak var bellButton: ShadowButton!
    
    private func shakeAndPlaySound() {
        bellButton.shake()
        bellButton.playSound(file: bellSound, ext: mp3)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Timer.scheduledTimer(withTimeInterval: delayAfterViewAppears, repeats: false) {
            [weak self] timer in
            self?.shakeAndPlaySound()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bellButton.imageView?.contentMode = .scaleAspectFit
    }
    
    @IBAction func bellPressed(_ sender: ShadowButton) {
        shakeAndPlaySound()
    }
}
