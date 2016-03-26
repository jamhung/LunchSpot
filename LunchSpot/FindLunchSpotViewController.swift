//
//  FindLunchSpotViewController.swift
//  LunchSpot
//
//  Created by James Hung on 3/5/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import MapKit

protocol FindLunchSpotViewModelProtocol {
    
    func currentLocationButtonPressed()
    
    func locationPickerButtonPressed()
    
    func findLunchSpotButtonPressed()
    
    func beginLocationUpdates()
}

@objc(FindLunchSpotViewController)
class FindLunchSpotViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var findLunchSpotButton: UIButton!
    @IBOutlet weak var updateLocationView: UIView!
    @IBOutlet weak var updateLocationButton: UIButton!
    @IBOutlet weak var placemarkLabel: UILabel!
    @IBOutlet weak var findLunchSpotView: UIView!
    @IBOutlet weak var currentLocationView: UIView!
    @IBOutlet weak var locationDescriptorLabel: UILabel!
    @IBOutlet weak var findLunchLoadingView: UIActivityIndicatorView!
    
    var launchScreen: LSLaunchScreen!
    var locationAnnotationPin = MKPointAnnotation()
    var viewModel: FindLunchSpotViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.renderLaunchScreen()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        
        self.findLunchSpotButton.setTitle("Find Lunch Spot", forState: .Normal)
        self.findLunchSpotButton.userInteractionEnabled = true
        self.updateLocationButton.userInteractionEnabled = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.isMovingToParentViewController() {
            self.viewModel.beginLocationUpdates()
        }
    }
    
    func renderLaunchScreen() {
        self.launchScreen = LSLaunchScreen(frame: self.view.bounds)
        self.launchScreen.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = NSLayoutConstraint(item: self.launchScreen, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0)
        
        let leadingConstraint = NSLayoutConstraint(item: self.launchScreen, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0)
        
        let trailingConstraint = NSLayoutConstraint(item: self.launchScreen, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0)
        
        let bottomConstraint = NSLayoutConstraint(item: self.launchScreen, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        self.view.addSubview(self.launchScreen)
        self.view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    
    func hideLaunchScreen() {
        if self.launchScreen != nil {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.launchScreen.alpha = 0.0
                }) { (success) -> Void in
                    self.launchScreen.removeFromSuperview()
            }
        }
    }
    
    func configureView() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        self.findLunchSpotView.layer.cornerRadius = 5.0
        self.findLunchSpotView.clipsToBounds = true
        
        self.locationDescriptorLabel.textColor = UIColor(hexString: "B6B6B6")
        self.updateLocationView.layer.cornerRadius = 5.0
        self.updateLocationView.clipsToBounds = true
        self.updateLocationView.layer.borderWidth = 0.5
        self.updateLocationView.layer.borderColor = UIColor(hexString: "B6B6B6").CGColor
        
        self.currentLocationView.layer.cornerRadius = CGRectGetWidth(self.currentLocationView.frame)/2.0
        self.currentLocationView.clipsToBounds = true
        self.currentLocationView.layer.borderWidth = 0.5
        self.currentLocationView.layer.borderColor = UIColor(hexString: "B6B6B6").CGColor
    }
}

// MARK: Button Handler Methods

extension FindLunchSpotViewController {
    @IBAction func updateLocationButtonPressed(sender: AnyObject) {
        self.updateLocationButton.alpha = 1.0
        self.viewModel.locationPickerButtonPressed()
    }
    
    @IBAction func currentLocationButtonPressed(sender: AnyObject) {
        self.currentLocationButton.alpha = 1.0
        self.viewModel.currentLocationButtonPressed()
    }
    
    @IBAction func findLunchSpotButtonPressed(sender: AnyObject) {
        self.findLunchSpotButton.alpha = 1.0
        
        self.findLunchSpotButton.setTitle("", forState: .Normal)
        self.findLunchLoadingView.startAnimating()
        
        self.findLunchSpotButton.userInteractionEnabled = false
        self.updateLocationButton.userInteractionEnabled = false
        
        self.viewModel.findLunchSpotButtonPressed()
    }
    
    @IBAction func changeLocationButtonTouchDown(sender: AnyObject) {
        self.updateLocationButton.alpha = 0.9
    }
    
    @IBAction func changeLocationButtonDragExit(sender: AnyObject) {
        self.updateLocationButton.alpha = 1.0
    }
    
    @IBAction func findLunchSpotButtonDragExit(sender: AnyObject) {
        self.findLunchSpotButton.alpha = 1.0
    }
    
    @IBAction func findLunchSpotButtonTouchDown(sender: AnyObject) {
        self.findLunchSpotButton.alpha = 0.9
    }
    
    @IBAction func currentLocationButtonTouchDown(sender: AnyObject) {
        self.currentLocationButton.alpha = 0.9
    }
    
    @IBAction func currentLocationButtonDragExit(sender: AnyObject) {
        self.currentLocationButton.alpha = 1.0
    }
}

extension FindLunchSpotViewController: FindLunchSpotViewProtocol {
    
    func lunchSpotFound() {
        self.findLunchLoadingView.stopAnimating()
    }
    
    func updateMapRegion(region: MKCoordinateRegion, animated: Bool) {
        self.mapView.setRegion(region, animated: animated)
    }
    
    func updateLocationPickerTitle(title: String) {
        self.placemarkLabel.text = title
    }
    
    func updateMapPin(withCoordinate coordinate: CLLocationCoordinate2D, name: String) {
        self.hideLaunchScreen()
        
        self.mapView.removeAnnotation(self.locationAnnotationPin)
        self.locationAnnotationPin.coordinate = coordinate
        self.locationAnnotationPin.title = name
        self.mapView.addAnnotation(self.locationAnnotationPin)
    }
    
    func locationAccessDenied() {
        self.hideLaunchScreen()
    }

}