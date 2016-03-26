//
//  LSCache.swift
//  LunchSpot
//
//  Created by James Hung on 3/23/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import CoreLocation

class LSCache: NSCache {
    
    static let nearbyThresholdMeters = 300.0
    
    var locationKeys = [CLLocation]()
    
    func setObject(obj: AnyObject, forLocationKey key: CLLocation) {
        self.setObject(obj, forKey: key)
        self.locationKeys.append(key)
    }
    
    func objectForNearbyLocation(location: CLLocation) -> AnyObject? {
        for locationKey in self.locationKeys {
            if location.distanceFromLocation(locationKey) <= LSCache.nearbyThresholdMeters {
                return self.objectForKey(locationKey)
            }
        }
        return nil
    }
}
