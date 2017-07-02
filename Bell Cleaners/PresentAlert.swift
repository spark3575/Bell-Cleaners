//
//  PresentAlert.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/26/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class PresentAlert: UIAlertController {
    
    func presentAlert(fromController controller: UIViewController, title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        controller.present(alert, animated: true)
    }
    
    func presentSettingsActionAlert(fromController controller: UIViewController, title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.Alerts.Actions.Settings, style: .default, handler: { (alert) in
            guard let settingsURL = Constants.URLs.Settings else { return }
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        controller.present(alert, animated: true)
    }
}
