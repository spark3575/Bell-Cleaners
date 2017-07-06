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
    
    var orders = [Order]()
    var orderIDs = [String]()
    var currentUserOrders = [Order]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tabelView.dataSource = self
        tabelView.delegate = self
//        DataService.instance.ordersRef.observeSingleEvent(of: .value) { (snapshot) in
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for snap in snapshot {
//                    print("Snap: \(snap)")
//                    if let orderDict = snap.value as? [String: AnyObject] {
//                        let key = snap.key
//                        let order = Order(orderID: key, orderData: orderDict)
//                        self.orders.append(order)
//                    }
//                }
//            }
//        }
        DataService.instance.currentUserOrders.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    print("Snap: \(snap)")
                    let key = snap.key
                    self.orderIDs.append(key)
                }
            }
            print(self.orderIDs)
        }
        for x in 0..<orderIDs.count {
            let key = orderIDs[x]
            DataService.instance.ordersRef.queryEqual(toValue: key).observeSingleEvent(of: .value) { (snapsho) in
                if let currentOrderDict = snapsho.value as? [String: AnyObject] {
                    let order = Order(orderID: key, orderData: currentOrderDict)
                    self.currentUserOrders.append(order)
                    print(self.currentUserOrders)
                }
            }
            
        }
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
