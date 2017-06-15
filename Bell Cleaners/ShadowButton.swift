//
//  ShadowButton.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/22/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import AVFoundation

@IBDesignable
class ShadowButton: UIButton {
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    func setup() {
        layer.shadowColor = layerShadowColor
        layer.shadowOffset = layerShadowOffset
        layer.shadowOpacity = layerShadowOpacity
        layer.shadowRadius = layerShadowRadius
        layer.cornerRadius = layerCornerRadius
    }
    
    func shake () {        
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
    
    var audioPlayer = AVAudioPlayer()
    
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
