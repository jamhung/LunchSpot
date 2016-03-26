//
//  FindLunchSpotWireframe.swift
//  LunchSpot
//
//  Created by James Hung on 3/9/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class FindLunchSpotWireframe: NSObject {
    
    class func setupFindLunchSpotModule() -> UIViewController {
        let findLunchSpotViewController = FindLunchSpotViewController()
        let findLunchSpotViewModel = FindLunchSpotViewModel(view: findLunchSpotViewController)
        
        findLunchSpotViewModel.wireframe = FindLunchSpotWireframe()
        findLunchSpotViewController.viewModel = findLunchSpotViewModel
        
        return findLunchSpotViewController
    }
    
    func presentUpdateLocationView(region: MKCoordinateRegion?, fromView: FindLunchSpotViewProtocol, delegate: ChangeLocationViewModelDelegate?) {
        let changeLocationView = ChangeLocationWireframe.setupChangeLocationModule(region, delegate: delegate)
        
        if let sourceView = fromView as? UIViewController {
            sourceView.navigationController?.presentViewController(changeLocationView, animated: true, completion: nil)
        }
    }

    func presentLunchDetailsView(venueJSON: JSON, themeImage: UIImage, fromView: FindLunchSpotViewProtocol) {
        let lunchDetailsViewController = LunchDetailsWireframe.setupLunchDetailsModule(venueJSON, themeImage: themeImage)
        
        if let sourceView = fromView as? UIViewController {
            sourceView.navigationController?.pushViewController(lunchDetailsViewController, animated: true)
            sourceView.navigationController?.themeNavigationBar(withImage: themeImage, showKeyline: false)
        }
    }
    
    func presentLunchSpotSearchErrorAlert(fromView: FindLunchSpotViewProtocol) {
        let searchErrorAlert = UIAlertController(title: "Error searching for a lunch spot", message: "Please try again!", preferredStyle: .Alert)
        
        if let viewController = fromView as? UIViewController {
            viewController.navigationController?.presentViewController(searchErrorAlert, animated: true, completion: nil)
        }
    }
    
    func presentLocationDeniedAlert(fromView: FindLunchSpotViewProtocol) {
        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "In order for a lunch spot to be suggested near you, please open this app's settings and set location access to 'While Using the App'.",
            preferredStyle: .Alert)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alertController.addAction(openAction)
        
        if let viewController = fromView as? UIViewController {
            viewController.navigationController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
