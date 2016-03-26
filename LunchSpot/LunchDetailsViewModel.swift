//
//  LunchDetailsViewModel.swift
//  LunchSpot
//
//  Created by James Hung on 3/10/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

protocol LunchDetailsViewModelProtocol {
    func tipAtIndex(index: Int) -> JSON
    func numberOfTips() -> Int
    func numberOfPhotos() -> Int
    func headerImage() -> UIImage
    func venueData() -> JSON
    func venueName() -> String
    func photoSet() -> [JSON]
    
    func viewLoaded()
    func callButtonPressed()
    func mapButtonPressed()
    func menuButtonPressed()
}

protocol LunchDetailsViewProtocol {
    func refreshTips()
    func refreshPhotos()
}

class LunchDetailsViewModel: NSObject {
    
    var wireframe: LunchDetailsWireframe!
    var view: LunchDetailsViewProtocol!
    
    let apiService: LSFourSquareAPIService.Type
    let venueJSON: JSON
    let themeImage: UIImage
    private var tips = JSON([String: AnyObject]())
    private var photos = [JSON]()

    init(venueJSON: JSON, themeImage: UIImage, apiService: LSFourSquareAPIService.Type = LSFourSquareAPIService.self) {
        self.apiService = apiService
        self.venueJSON = venueJSON
        self.themeImage = themeImage
        super.init()
    }
    
    func lunchSpotID() -> String {
        return self.venueJSON["id"].stringValue
    }   
}

extension LunchDetailsViewModel: LunchDetailsViewModelProtocol {
    func photoSet() -> [JSON] {
        return self.photos
    }
    
    func numberOfPhotos() -> Int {
        return self.photos.count
    }
    
    func numberOfTips() -> Int {
        return self.tips.count
    }
    
    func tipAtIndex(index: Int) -> JSON {
        return self.tips[index]
    }
    
    func venueData() -> JSON {
        return self.venueJSON
    }
    
    func headerImage() -> UIImage {
        return self.themeImage
    }
    
    func venueName() -> String {
        return self.venueJSON["name"].stringValue
    }
    
    func viewLoaded() {
        self.apiService.fetchTipsForVenue(self.lunchSpotID()) { (response, error) -> Void in
            if let tipsResponse = response {
                self.tips = tipsResponse["items"]
                self.view.refreshTips()
            }
        }
        
        self.apiService.fetchPhotosForVenue(self.lunchSpotID()) { (response, error) -> Void in
            if let photosResponse = response {
                var photosArray = photosResponse.arrayValue
                photosArray.removeFirst()
                self.photos = photosArray
                self.view.refreshPhotos()
            }
        }
        
    }
    
    func menuButtonPressed() {
        if let mobileURLString = self.venueJSON["menu"]["mobileUrl"].string {
            let menuURL = NSURL(string: mobileURLString)
            if let url = menuURL {
                self.wireframe.presentLunchMenuView(url, fromView: self.view, themeImage: self.themeImage)
            }
        } else {
            self.wireframe.presentNoMenuAlert(self.view)
        }
    }
    
    func mapButtonPressed() {
        let latitude = self.venueJSON["location"]["lat"].doubleValue
        let longitude = self.venueJSON["location"]["lng"].doubleValue
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let venueName = self.venueJSON["name"].stringValue
        self.wireframe.presentMapView(coordinate, venueName: venueName, fromView: self.view, themeImage: self.themeImage)
    }
    
    func callButtonPressed() {
        let phoneNumber = self.venueJSON["contact"]["phone"].stringValue
        let phoneURL = NSURL(string: "tel:\(phoneNumber)")!
        if UIApplication.sharedApplication().canOpenURL(phoneURL) {
            UIApplication.sharedApplication().openURL(phoneURL)
        }
    }
}
