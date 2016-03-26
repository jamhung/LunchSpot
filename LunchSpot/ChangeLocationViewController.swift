//
//  ChangeLocationViewController.swift
//  LunchSpot
//
//  Created by James Hung on 2/29/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import MapKit

@objc(ChangeLocationViewController)
class ChangeLocationViewController: UIViewController {

    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var dividerLine: UIView!
    @IBOutlet weak var dividerLineHeightConstraint: NSLayoutConstraint!
    
    var region: MKCoordinateRegion?    
    var viewModel: ChangeLocationViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupTableView()
        self.setupSearchBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.searchTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchTextField.resignFirstResponder()
    }
    
    func cancelButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = "Set Location"
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("cancelButtonPressed"))
        cancelButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(hexString: "727272"), NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 18.0)!], forState: .Normal)
        self.navigationItem.rightBarButtonItem = cancelButton
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor(hexString: "727272"),
            NSFontAttributeName: UIFont(name: "Avenir-Book", size: 18)!
        ]
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor(hexString: "727272")
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupTableView() {
        self.dividerLineHeightConstraint.constant = 0.5
        self.dividerLine.backgroundColor = UIColor(hexString: "B6B6B6")
        
        self.searchResultsTableView.tableFooterView = UIView()
        self.searchResultsTableView.delegate = self
        self.searchResultsTableView.dataSource = self
        self.searchResultsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        self.searchResultsTableView.registerNib(UINib(nibName: LocationTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: LocationTableViewCell.reuseIdentifier)
        self.searchResultsTableView.estimatedRowHeight = 70
        self.searchResultsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupSearchBar() {
        self.searchBarView.layer.cornerRadius = 5.0
        self.searchBarView.clipsToBounds = true
        self.searchBarView.layer.borderWidth = 0.5
        self.searchBarView.layer.borderColor = UIColor(hexString: "B6B6B6").CGColor
        self.searchBarView.backgroundColor = UIColor.whiteColor()
        self.searchTextField.addTarget(self, action: Selector("textFieldValueChanged"), forControlEvents: .EditingChanged)
        self.searchTextField.textColor = UIColor(hexString: "727272")
        self.searchTextField.tintColor = UIColor(hexString: "2196F3")
    }
    
    func textFieldValueChanged() {
        if let searchText = self.searchTextField.text {
            self.viewModel.searchLocations(withQuery: searchText)
        }
    }
}

extension ChangeLocationViewController: ChangeLocationViewProtocol {
    func refreshView() {
        self.searchResultsTableView.reloadData()
    }
}

extension ChangeLocationViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(LocationTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! LocationTableViewCell
        let mapItem = self.viewModel.locationAtIndex(indexPath.row)
        cell.configure(withTitle: mapItem.name, subtitle: mapItem.placemark.ls_placemarkLocationDescription())
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfLocations()
    }
}

extension ChangeLocationViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.viewModel.numberOfLocations() == 0 {
            return 60
        }
        return 0.01
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = UIView()
        let noResults = UILabel()
        noResults.translatesAutoresizingMaskIntoConstraints = false
        noResults.font = UIFont(name: "Avenir-Book", size: 15.0)
        noResults.textColor = UIColor(hexString: "B6B6B6")
        noResults.textAlignment = .Center
        noResults.text = "No results to display"
        
        let topConstraint = NSLayoutConstraint(item: noResults, attribute: .Top, relatedBy: .Equal, toItem: sectionHeader, attribute: .Top, multiplier: 1.0, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: noResults, attribute: .Leading, relatedBy: .Equal, toItem: sectionHeader, attribute: .Leading, multiplier: 1.0, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: noResults, attribute: .Trailing, relatedBy: .Equal, toItem: sectionHeader, attribute: .Trailing, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: noResults, attribute: .Bottom, relatedBy: .Equal, toItem: sectionHeader, attribute: .Bottom, multiplier: 1.0, constant: 0)
        
        sectionHeader.addSubview(noResults)
        sectionHeader.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        
        return sectionHeader
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.viewModel.updateLocationAtIndex(indexPath.row)
    }
}

extension CLPlacemark {
    func ls_placemarkLocationDescription() -> String {
        
        var descriptionAttributes = [String]()
        
        if let streetAddress = self.thoroughfare {
            descriptionAttributes.append(streetAddress)
        }
        
        if let city = self.locality {
            descriptionAttributes.append(city)
        }
        
        if let state = self.administrativeArea {
            descriptionAttributes.append(state)
        }
        
        return descriptionAttributes.joinWithSeparator(", ")
        
    }
}
