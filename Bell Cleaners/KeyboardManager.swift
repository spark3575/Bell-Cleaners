//
//  KeyboardManager.swift
//  Bell Cleaners
//
//  Created by Shin Park on 6/30/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

public class KeyboardManager {
    
    var notifyFromObject: Any?
    var observer: Any
    public var stackViewToMove: [UIStackView] = []
    public var textFieldToMove: [UITextField] = []
    public var viewOfVC: [UIView] = []
    
    public init(observer: Any, viewOfVC: [UIView], stackViewToMove: [UIStackView], textFieldToMove: [UITextField], notifyFromObject: Any? = nil) {
        self.notifyFromObject = notifyFromObject
        self.observer = observer
        self.stackViewToMove = stackViewToMove
        self.textFieldToMove = textFieldToMove
        self.viewOfVC = viewOfVC
    }
    
    public func viewMoveWhenKeyboardWillShow() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(KeyboardManager.viewMover), name: NSNotification.Name.UIKeyboardWillShow, object: notifyFromObject)
    }
    
    @objc public func viewMover(notification: NSNotification) {
        for view in viewOfVC {
            for stackView in stackViewToMove {
                for textField in textFieldToMove {
                    if let keyboardRectValue = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                        let keyboardHeight = keyboardRectValue.height
                        let targetY = view.frame.size.height - keyboardHeight - Constants.Keyboards.SpaceToText - textField.frame.size.height
                        let textFieldY = stackView.frame.origin.y + textField.frame.origin.y
                        let differenceY = targetY - textFieldY
                        let targetOffsetY = stackView.frame.origin.y + differenceY
                        view.layoutIfNeeded()
                        UIView.animate(withDuration: Constants.Animations.Keyboard.DurationShow, animations: {
                            stackView.frame.origin.y = targetOffsetY
                            view.layoutIfNeeded()
                        })
                    }
                }
            }
        }
    }
}
