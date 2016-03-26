//
//  LSFourSquareAPIService.swift
//  LunchSpot
//
//  Created by James Hung on 2/21/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreLocation

class LSFourSquareAPIService: NSObject {
    static let clientID = "RCJ13N45WDKBVDL5GWVCXSVY11UDNQOA4UGQ0RH5TH0LDDSO"
    static let clientSecret = "G3TW4D4YRH20TIQ501EM5D2ICC354MHDMRTF0NJIMRUZVIPZ"
    static let apiVersionDate = "20140806"
    static let venueAPIBaseURL = "https://api.foursquare.com/v2/venues/"
    static let lunchSpotCache = LSCache()
    
    class func requiredAPIParams() -> [String: AnyObject] {
        return [
            "client_id": LSFourSquareAPIService.clientID,
            "client_secret": LSFourSquareAPIService.clientSecret,
            "v": LSFourSquareAPIService.apiVersionDate
        ]
    }
    
    class func chooseRandomLunchSpot(lunchSpots: JSON) -> JSON {
        var lunchSpotArray = [JSON]()
        
        for group in lunchSpots["response"]["groups"].arrayValue {
            for lunchSpot in group["items"].arrayValue {
                lunchSpotArray.append(lunchSpot)
            }
        }
        
        let chosenLunchResultIndex = Int(arc4random_uniform(UInt32(lunchSpotArray.count)))
        
        return lunchSpotArray[chosenLunchResultIndex]
    }
    
    class func fetchRandomLunchSpot(atLocation location: CLLocation, completion: (response: JSON?, error: Bool) -> Void) {
        var params = self.requiredAPIParams()
        
        if let lunchSpotResponse = self.lunchSpotCache.objectForNearbyLocation(location) {
            let lunchSpots = JSON(lunchSpotResponse)
            let chosenLunchSpot = self.chooseRandomLunchSpot(lunchSpots)
            completion(response: chosenLunchSpot, error: false)
            return
        }
        
        params["ll"] = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        params["venuePhotos"] = "1"
        params["query"] = "lunch brunch"
        params["price"] = "1,2,3"
        params["sortByDistance"] = "0"
        
        Alamofire.request(.GET, "\(self.venueAPIBaseURL)explore", parameters: params)
        .responseJSON { response in
            if let responseValue = response.result.value {
                
                self.lunchSpotCache.setObject(responseValue, forLocationKey: location)
                
                let lunchSpots = JSON(responseValue)
                let chosenLunchSpot = self.chooseRandomLunchSpot(lunchSpots)
                completion(response: chosenLunchSpot, error: false)
                
            } else {
                completion(response: nil, error: true)
            }
        }
    }

    class func fetchTipsForVenue(venueID: String, completion:(response: JSON?, error: Bool) -> Void) {
        var params = self.requiredAPIParams()
        params["sort"] = "popular"
        params["limit"] = "10"
        
        Alamofire.request(.GET, "\(self.venueAPIBaseURL)\(venueID)/tips", parameters: params).responseJSON { (response) -> Void in
            if let responseValue = response.result.value {
                let tipsJSON = JSON(responseValue)["response"]["tips"]
                completion(response: tipsJSON, error: false)
            } else {
                completion(response: nil, error: true)
            }
        }
    }
    
    class func fetchPhotosForVenue(venueID: String, completion:(response: JSON?, error: Bool) -> Void) {
        let params = self.requiredAPIParams()
        
        Alamofire.request(.GET, "\(self.venueAPIBaseURL)\(venueID)/photos", parameters: params).responseJSON { (response) -> Void in
            if let responseValue = response.result.value {
                let photosJSON = JSON(responseValue)["response"]["photos"]["items"]
                completion(response: photosJSON, error: false)
            } else {
                completion(response: nil, error: true)
            }
        }
    }
}
