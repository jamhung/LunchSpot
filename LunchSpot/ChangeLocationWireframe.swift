//
//  ChangeLocationWireframe.swift
//  LunchSpot
//
//  Created by James Hung on 3/12/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import MapKit

class ChangeLocationWireframe: NSObject {
    
    class func setupChangeLocationModule(region: MKCoordinateRegion?, delegate: ChangeLocationViewModelDelegate?) -> UINavigationController {
        
        let changeLocationViewController = ChangeLocationViewController()
        let changeLocationNavigationController = UINavigationController(rootViewController: changeLocationViewController)
        let changeLocationViewModel = ChangeLocationViewModel(region: region)
        
        changeLocationViewController.viewModel = changeLocationViewModel
        changeLocationViewModel.delegate = delegate
        changeLocationViewModel.view = changeLocationViewController
        changeLocationViewModel.wireframe = ChangeLocationWireframe()
        
        return changeLocationNavigationController
    }
    
    func dismiss(view: UIViewController) {
        view.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
