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
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var orders = [Order]()
    var orderIDs = [String]()
    var currentUserOrders = [Order]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        spinner.startAnimating()
        DataService.instance.ordersRef.observe(.childChanged, with: { (snapshot) in
            self.spinner.stopAnimating()
            if let changedOrderDict = snapshot.value as? [String: AnyObject] {
                let changedOrderID = snapshot.key
                let changedOrder = Order(orderID: changedOrderID, orderData: changedOrderDict)
                if let index = self.currentUserOrders.index(where: {$0.orderID == changedOrderID}) {
                    self.currentUserOrders[index] = changedOrder
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows!, with: .none)
                    }                    
                }
            }
        })
        spinner.startAnimating()
        DataService.instance.ordersRef.queryOrdered(byChild: Constants.Literals.OrderNumber).observeSingleEvent(of: .value, with: { (snapshot) in
            self.spinner.stopAnimating()
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let orderDict = snap.value as? [String: AnyObject] {
                        let key = snap.key
                        let order = Order(orderID: key, orderData: orderDict)
                        if order.userID == Auth.auth().currentUser?.uid {
                            self.currentUserOrders.insert(order, at: 0)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUserOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let order = currentUserOrders[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView.Cell.Identifier.Order) as? OrderCell {
            cell.configureCell(order: order)
            return cell
        } else {
            return OrderCell()
        }
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
