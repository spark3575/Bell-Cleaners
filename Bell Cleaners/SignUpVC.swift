//
//  SignUpVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/26/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = signUpNavBarTitle
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = emptyLeftBarButtonItemTitle
        navigationItem.backBarButtonItem = backButton
    }
}
