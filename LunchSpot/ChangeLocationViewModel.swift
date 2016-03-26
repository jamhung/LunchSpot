//
//  ChangeLocationViewModel.swift
//  LunchSpot
//
//  Created by James Hung on 3/12/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import MapKit

protocol ChangeLocationViewModelProtocol {
    func searchLocations(withQuery query: String)
    func numberOfLocations() -> Int
    func locationAtIndex(index: Int) -> MKMapItem
    func updateLocationAtIndex(index: Int)
}

protocol ChangeLocationViewProtocol {
    func refreshView()
}

protocol ChangeLocationViewModelDelegate {
    func didUpdateLocation(withMapItem mapItem: MKMapItem)
}

class ChangeLocationViewModel: NSObject {

    var wireframe: ChangeLocationWireframe!
    var view: ChangeLocationViewProtocol!
    
    var delegate: ChangeLocationViewModelDelegate?
    var region: MKCoordinateRegion?
    var mapItems = [MKMapItem]()
    
    init(region: MKCoordinateRegion?) {
        self.region = region
        super.init()
    }
}

extension ChangeLocationViewModel: ChangeLocationViewModelProtocol {
    func searchLocations(withQuery query: String) {
        if query.characters.count >= 3 {
            
            self.searchLocations(query, completion: { (response, error) -> Void in
                guard let searchResponse = response else {
                    print("No response")
                    return
                }
                self.mapItems = searchResponse.mapItems
                self.view.refreshView()
            })
            
        } else {
            self.mapItems = []
        }
        self.view.refreshView()
    }
    
    func searchLocations(query: String, completion: (MKLocalSearchResponse?, NSError?) -> Void) {
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: searchRequest)
        search.startWithCompletionHandler { (response, error) -> Void in
            completion(response, error)
        }
    }
    
    func numberOfLocations() -> Int {
        return self.mapItems.count
    }
    
    func locationAtIndex(index: Int) -> MKMapItem {
        return self.mapItems[index]
    }
    
    func updateLocationAtIndex(index: Int) {
        let location = self.mapItems[index]
        self.delegate?.didUpdateLocation(withMapItem: location)
        
        if let viewController = self.view as? UIViewController {
            self.wireframe.dismiss(viewController)
        }
    }
}
