//
//  LunchDetailsWireframe.swift
//  LunchSpot
//
//  Created by James Hung on 3/10/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

class LunchDetailsWireframe: NSObject {
    
    class func setupLunchDetailsModule(venueJSON: JSON, themeImage: UIImage) -> UIViewController {
        
        let lunchDetailsVC = LunchDetailsViewController()
        let lunchDetailsViewModel = LunchDetailsViewModel(venueJSON: venueJSON, themeImage: themeImage)
        lunchDetailsViewModel.wireframe = LunchDetailsWireframe()
        lunchDetailsVC.viewModel = lunchDetailsViewModel
        lunchDetailsViewModel.view = lunchDetailsVC
        
        return lunchDetailsVC
    }
    
    func presentMapView(centerCoordinate: CLLocationCoordinate2D, venueName: String, fromView: LunchDetailsViewProtocol, themeImage: UIImage) {
        
        let lunchMapViewController = LunchMapViewController(centerCoordinate: centerCoordinate, venueName: venueName)
        
        if let sourceView = fromView as? UIViewController {
            let navigationController = UINavigationController(rootViewController: lunchMapViewController)
            sourceView.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
            navigationController.themeNavigationBar(withImage: themeImage, showKeyline: true)
        }
    }
    
    func presentLunchMenuView(menuURL: NSURL, fromView: LunchDetailsViewProtocol, themeImage: UIImage) {
        let lunchMenuViewController = LunchMenuViewController()
        lunchMenuViewController.menuURL = menuURL
       
        if let sourceView = fromView as? UIViewController {
            let navigationController = UINavigationController(rootViewController: lunchMenuViewController)
            sourceView.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
            navigationController.themeNavigationBar(withImage: themeImage, showKeyline: true)
        }
    }
    
    func presentNoMenuAlert(fromView: LunchDetailsViewProtocol) {
        if let sourceView = fromView as? UIViewController {
            let alertController = UIAlertController(title: "No menu available", message: "We couldn't find an online menu!", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            sourceView.navigationController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
