//
//  OrdersVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 7/5/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import Firebase

class OrdersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tabelView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tabelView.dataSource = self
        tabelView.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tabelView.dequeueReusableCell(withIdentifier: Constants.TableView.Cell.Identifier.Orders) as! OrdersCell
    }

    @IBAction func didTapSignOut(_ sender: SignOutButton) {
        AuthService.instance.signOut(signedOut: { (signedOut) in
            if signedOut {
                self.performSegue(withIdentifier: Constants.Segues.UnwindToBellCleanersVC, sender: self)
                return
            }
        })
    }
}
