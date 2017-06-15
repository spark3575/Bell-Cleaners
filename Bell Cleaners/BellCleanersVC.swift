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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bellButton.imageView?.contentMode = .scaleAspectFit
    }
}

