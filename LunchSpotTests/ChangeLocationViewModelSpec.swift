//
//  ChangeLocationViewModelSpec.swift
//  LunchSpot
//
//  Created by James Hung on 3/20/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import Quick
import Nimble
import MapKit
@testable import LunchSpot

class ChangeLocationViewModelSpec: QuickSpec {
    override func spec() {
        
        describe("ChangeLocationViewModel") {
            var viewModel: ChangeLocationViewModel!
            var region: MKCoordinateRegion!
            
            beforeEach {
                region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(1.0, 1.0), MKCoordinateSpanMake(0.02, 0.02))
                viewModel = ChangeLocationViewModel(region: region)
            }
            
            describe("Initialization") {
                
                context("when initializing with non-nil region") {
                    it("should have a non-nil region property") {
                        expect(viewModel.region?.center.latitude) == region.center.latitude
                        expect(viewModel.region?.center.longitude) == region.center.longitude
                        expect(viewModel.region?.span.latitudeDelta) == region.span.latitudeDelta
                        expect(viewModel.region?.span.longitudeDelta) == region.span.longitudeDelta
                    }
                }
                
                context("When initializing with nil region") {
                    beforeEach {
                        viewModel = ChangeLocationViewModel(region: nil)
                    }
                    
                    context("When initializing with nil region") {
                        it("should have a nil region property") {
                            expect(viewModel.region).to(beNil())
                        }
                    }
                }
            }
            
            describe("Location Data Source Methods") {
                let mapItemOne = MKMapItem()
                let mapItemTwo = MKMapItem()
                let mapItems = [mapItemOne, mapItemTwo]

                beforeEach {
                    viewModel.mapItems = mapItems
                }
                
                describe("numberOfLocations") {
                    it("should return number of items in mapItems property") {
                        let numberOfLocations = viewModel.numberOfLocations()
                        expect(numberOfLocations) == mapItems.count
                    }
                }
                
                describe("locationAtIndex") {
                    it("should return the MKMapItem found at the given index within mapItems") {
                        var mapItem = viewModel.locationAtIndex(0)
                        expect(mapItem).to(beIdenticalTo(mapItemOne))
                        
                        mapItem = viewModel.locationAtIndex(1)
                        expect(mapItem).to(beIdenticalTo(mapItemTwo))
                    }
                }
            }
            
            describe("Location Search") {
                class viewModelMock: ChangeLocationViewModel {
                    override func searchLocations(query: String, completion: (MKLocalSearchResponse?, NSError?) -> Void) {
                        let searchResponse = MKLocalSearchResponse()
                        completion(searchResponse, nil)
                    }
                }
                
                class viewMock: ChangeLocationViewController {
                    var didRefreshView = false
                    
                    override func refreshView() {
                        self.didRefreshView = true
                    }
                }
                
                var view: viewMock!
                
                beforeEach {
                    viewModel = viewModelMock(region: region)
                    viewModel.view = viewMock()
                    view = viewModel.view as! viewMock
                }
                
                context("when search string is of sufficient length and search succeeds") {
                    it("should call refreshView of the view property") {
                        viewModel.searchLocations(withQuery: "test")
                        expect(view.didRefreshView).to(beTrue())
                    }
                }
                
                context("when search string is not sufficiently long") {
                    it("should call refreshView of the view property") {
                        viewModel.searchLocations(withQuery: "t")
                        expect(view.didRefreshView).to(beTrue())
                    }
                }
            }
            
        }
    }

}
