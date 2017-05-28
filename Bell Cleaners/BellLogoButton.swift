//
//  BellLogoButton.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/24/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import AVFoundation

class BellLogoButton: ShadowButton {
    
    func shake() {
        let shake = CABasicAnimation(keyPath: animationKeyPath)
        shake.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        shake.fromValue = shakeFromValue
        shake.toValue = shakeToValue
        shake.isRemovedOnCompletion = false
        shake.duration = shakeDuration
        shake.autoreverses = true
        shake.repeatCount = shakeRepeatCount
        
        self.layer.add(shake, forKey: nil)
    }
    
    private var audioPlayer = AVAudioPlayer()
    
    func playSound(file:String, ext:String) -> Void {
        do {
            let url = URL.init(fileURLWithPath: Bundle.main.path(forResource: file, ofType: ext)!)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
