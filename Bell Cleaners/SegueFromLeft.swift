//
//  SegueFromLeft.swift
//  Bell Cleaners
//
//  Created by Shin Park on 6/7/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class SegueFromLeft: UIStoryboardSegue {
    
    override func perform() {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: Constants.Animations.Segue.TranslationY)
        
        UIView.animate(withDuration: Constants.Animations.Segue.Duration, delay: Constants.Animations.Segue.Delay, options: UIViewAnimationOptions.curveEaseInOut, animations: { dst.view.transform = CGAffineTransform(translationX: Constants.Animations.Segue.TranslationX, y: Constants.Animations.Segue.TranslationY) }, completion: { finished in src.present(dst, animated: false, completion: nil) })
    }
}
