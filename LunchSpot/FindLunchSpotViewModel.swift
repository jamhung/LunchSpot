//
//  FindLunchSpotViewModel.swift
//  LunchSpot
//
//  Created by James Hung on 3/6/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SDWebImage
import SwiftyJSON

protocol FindLunchSpotViewProtocol: class {
    
    func locationAccessDenied()
    
    func updateMapPin(withCoordinate coordinate: CLLocationCoordinate2D, name: String)
    
    func updateMapRegion(region: MKCoordinateRegion, animated: Bool)
    
    func updateLocationPickerTitle(title: String)
    
    func lunchSpotFound()
}

class FindLunchSpotViewModel: NSObject {
    
    var currentDisplayPlacemark: CLPlacemark?
    var currentLocationPlacemark: CLPlacemark?
    
    var wireframe: FindLunchSpotWireframe!
    var locationManager: LSLocationManager
    var view: FindLunchSpotViewProtocol
    var apiService: LSFourSquareAPIService.Type
    var imageDownloadManager: SDWebImageManager
    
    init(view: FindLunchSpotViewProtocol, locationManager: LSLocationManager = LSLocationManager(), apiService: LSFourSquareAPIService.Type = LSFourSquareAPIService.self, imageDownloadManager: SDWebImageManager = SDWebImageManager.sharedManager()) {
        self.locationManager = locationManager
        self.view = view
        self.apiService = apiService
        self.imageDownloadManager = imageDownloadManager
        
        super.init()
        
        self.locationManager.delegate = self
    }
}

// MARK: Helper Methods
extension FindLunchSpotViewModel {
    
    func updateLocationDelegate(withPlacemark placemark: CLPlacemark?, animated: Bool) {
        if let mark = placemark, let coordinate = mark.location?.coordinate, placemarkName = mark.name {
            let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.02, 0.02))
            view.updateMapRegion(region, animated: animated)
            view.updateLocationPickerTitle(placemarkName)
            view.updateMapPin(withCoordinate: coordinate, name: placemarkName)
        }
    }
    
    func currentDisplayRegion() -> MKCoordinateRegion? {
        let span = MKCoordinateSpanMake(0.005, 0.005)
        if let location = self.currentDisplayPlacemark?.location {
            let region = MKCoordinateRegionMake(location.coordinate, span)
            return region
        }
        return nil
    }
}

// MARK: ChangeLocationViewModelLocation Delegate Methods

extension FindLunchSpotViewModel: ChangeLocationViewModelDelegate {
    
    func didUpdateLocation(withMapItem mapItem: MKMapItem) {
        self.currentDisplayPlacemark = mapItem.placemark
        self.updateLocationDelegate(withPlacemark: self.currentDisplayPlacemark, animated: false)
    }
}

// MARK: FindLunchSpot Event Handler Methods
extension FindLunchSpotViewModel: FindLunchSpotViewModelProtocol {
    
    func beginLocationUpdates() {
         self.locationManager.startUpdatingLocation()
    }
    
    func currentLocationButtonPressed() {
        self.currentDisplayPlacemark = self.currentLocationPlacemark
        self.updateLocationDelegate(withPlacemark: self.currentLocationPlacemark, animated: true)
    }
    
    func findLunchSpotButtonPressed() {
        if let placemark = self.currentDisplayPlacemark {
            
            self.apiService.fetchRandomLunchSpot(atLocation: placemark.location!) { (response, error) -> Void in
                if let jsonResponse = response {
                    
                    
                    let featuredPhotoCount = jsonResponse["venue"]["featuredPhotos"]["count"].intValue
                    if featuredPhotoCount > 0 {
                        let photoURLPrefix = jsonResponse["venue"]["featuredPhotos"]["items"][0]["prefix"]
                        let photoURLSuffix = jsonResponse["venue"]["featuredPhotos"]["items"][0]["suffix"]
                        let photoURLString = "\(photoURLPrefix)500x500\(photoURLSuffix)"
                        
                        self.imageDownloadManager.downloadImageWithURL(NSURL(string: photoURLString), options: .HighPriority, progress: nil, completed: { (image, error, cacheType, finished, url) -> Void in
                            
                            self.view.lunchSpotFound()
                            let venueJSON = jsonResponse["venue"]
                            self.wireframe.presentLunchDetailsView(venueJSON, themeImage: image, fromView: self.view)
                        })
                    } else {
                        self.wireframe.presentLunchSpotSearchErrorAlert(self.view)
                    }
                } else {
                    self.wireframe.presentLunchSpotSearchErrorAlert(self.view)
                }
            }
        }
    }
    
    func locationPickerButtonPressed() {
        self.wireframe.presentUpdateLocationView(self.currentDisplayRegion(), fromView: self.view, delegate: self)
    }
}

// MARK: LSLocationManager Delegate Methods

extension FindLunchSpotViewModel: LSLocationManagerDelegate {
    
    func locationAccessDenied(locationManager: LSLocationManager) {
        self.view.locationAccessDenied()
        self.wireframe.presentLocationDeniedAlert(self.view)
    }
    
    func locationManager(manager: LSLocationManager, didUpdatePlacemark placemark: CLPlacemark) {
        self.currentLocationPlacemark = placemark
        
        if self.currentDisplayPlacemark == nil {
            self.currentDisplayPlacemark = placemark
            self.updateLocationDelegate(withPlacemark: self.currentLocationPlacemark, animated: false)
        }
    }

    func shouldSendPlacemarkData() -> Bool {
        return true
    }
}
