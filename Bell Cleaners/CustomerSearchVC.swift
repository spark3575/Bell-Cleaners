//
//  CustomerSearchVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 7/10/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import Firebase

class CustomerSearchVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    private var customer: Customer?
    private var customers = [Customer]()
    private var customerIDs = [String]()
    private var filteredCustomers = [Customer]()
    private var resultsController = UITableViewController()
    private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        spinner.startAnimating()
        DataService.instance.cutomersRef.queryOrdered(byChild: Constants.Literals.LastName).observeSingleEvent(of: .value, with: { (snapshot) in
            self.spinner.stopAnimating()
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let customerDict = snap.value as? [String: AnyObject] {
                        let key = snap.key
                        let customer = Customer(ID: key, customerData: customerDict)
                        self.customers.append(customer)
                        self.customerIDs.append(customer.userID)
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        spinner.startAnimating()
        DataService.instance.cutomersRef.observe(.childChanged, with: { (snapshot) in
            self.spinner.stopAnimating()
            if let changedcustomerDict = snapshot.value as? [String: AnyObject] {
                let key = snapshot.key
                let changedCustomer = Customer(ID: key, customerData: changedcustomerDict)
                if let index = self.customers.index(where: {$0.userID == changedCustomer.userID}) {
                    self.customers[index] = changedCustomer
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows!, with: .none)
                    }
                }
            }
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
//        filteredCustomers = customers.filter({ (customer: Customer) -> Bool in
//            if customer.lowercased().contains(searchTextField.text?.lowercased()) {
//                return true
//            } else {
//                return false
//            }
//        })
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return customers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customer = customers[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView.Cell.Identifier.Customer) as? CustomerCell {
            cell.configureCell(customer: customer)
            return cell
        } else {
            return CustomerCell()
        }
    }
 
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
