//
//  LSLocationManager.swift
//  LunchSpot
//
//  Created by James Hung on 2/20/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import CoreLocation

protocol LSLocationManagerDelegate : class {
    func locationAccessDenied(locationManager: LSLocationManager)
    func locationManager(manager: LSLocationManager, didUpdateLocation location: CLLocation)
    
    func shouldSendPlacemarkData() -> Bool
    func locationManager(manager: LSLocationManager, didUpdatePlacemark placemark: CLPlacemark)
}

// We want a few LSLocationManagerDelegate methods to be optional
extension LSLocationManagerDelegate {
    func locationManager(manager: LSLocationManager, didUpdateLocation location: CLLocation) {
        // Nothing to do
    }
    
    func locationManager(manager: LSLocationManager, didUpdatePlacemark placemark: CLPlacemark) {
        // Nothing to do
    }
    
    func shouldSendPlacemarkData() -> Bool {
        return false
    }
}

class LSLocationManager: NSObject {
    
    lazy var locationManager = CLLocationManager()
    lazy var geocoder = CLGeocoder()
    var delegate: LSLocationManagerDelegate?
    
    func startUpdatingLocation() {
        
        // Let delegate handle case where location authorization is Denied or Restricted.
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Restricted {
            self.delegate?.locationAccessDenied(self)
            return
        }
        
        self.locationManager.distanceFilter = 10
        self.locationManager.delegate = self
        
        // Request Location Access if we haven't yet.
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension LSLocationManager: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            manager.startUpdatingLocation()
        } else if status == .Denied {
            self.delegate?.locationAccessDenied(self)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        guard locations.count > 0 else {
            return
        }
        
        let updatedLocation = locations.last!
        
        delegate.locationManager(self, didUpdateLocation: updatedLocation)
        
        if delegate.shouldSendPlacemarkData() {
            self.geocoder.reverseGeocodeLocation(updatedLocation, completionHandler: { (placemarks, error) -> Void in
                if let placemarksData = placemarks {
                    delegate.locationManager(self, didUpdatePlacemark: placemarksData[0])
                } else if error != nil {
                    
                }
            })
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager failed with error: \(error)")
    }
}
