//
//  FindLunchSpotViewModelSpec.swift
//  LunchSpot
//
//  Created by James Hung on 3/20/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import Quick
import Nimble
import CoreLocation
import MapKit
import SDWebImage
import SwiftyJSON
@testable import LunchSpot

class FindLunchSpotViewModelSpec: QuickSpec {
    
    // Mock classes
    private class WebImageOperation: NSObject, SDWebImageOperation {
        @objc func cancel() { }
    }
    
    private class ImageDownloadManagerMock: SDWebImageManager {
        override func downloadImageWithURL(url: NSURL!, options: SDWebImageOptions, progress progressBlock: SDWebImageDownloaderProgressBlock!, completed completedBlock: SDWebImageCompletionWithFinishedBlock!) -> SDWebImageOperation! {
            
            completedBlock(UIImage(), nil, SDImageCacheType.None, true, NSURL())
            return WebImageOperation()
        }
    }
    
    private class ApiServiceMock: LSFourSquareAPIService {
        override class func fetchRandomLunchSpot(atLocation location: CLLocation, completion: (response: JSON?, error: Bool) -> Void) {
            let responseDict = [
                "venue": [
                    "featuredPhotos": [
                        "count": 1,
                        "items": [
                            ["prefix": "prefixOfURL", "suffix": "suffixOfUrl"]
                        ]
                    ]
                ]
            ]
            completion(response: JSON(responseDict), error: false)
        }
    }
    
    private class WireframeMock: FindLunchSpotWireframe {
        var didPresentLunchDetailsView = false
        
        override func presentLunchDetailsView(venueJSON: JSON, themeImage: UIImage, fromView: FindLunchSpotViewProtocol) {
            self.didPresentLunchDetailsView = true
        }
    }
    
    private class ViewMock: FindLunchSpotViewController {
        var lunchSpotWasFound = false
        
        override func lunchSpotFound() {
            self.lunchSpotWasFound = true
        }
    }
    
    override func spec() {
        
        describe("FindLunchSpotViewModel") {
            
            var viewModel: FindLunchSpotViewModel!
            var view: ViewMock!
            
            beforeEach {
                view = ViewMock()
                viewModel = FindLunchSpotViewModel(view: view)
                viewModel.imageDownloadManager = ImageDownloadManagerMock()
                viewModel.apiService = ApiServiceMock.self
                viewModel.wireframe = WireframeMock()
            }
            
            describe("Initialization") {
                
                context("when only the view object is passed in") {
                    
                    it("should have initialized the view, locationManager, and apiService properties") {
                        expect(viewModel.view).to(beIdenticalTo(view))
                        expect(viewModel.locationManager).toNot(beNil())
                        expect(viewModel.locationManager.delegate).to(beIdenticalTo(viewModel))
                        expect(viewModel.apiService).toNot(beNil())
                    }
                }
                
                context("when all init params are passed in") {
                    var locationManager: LSLocationManager!
                    var apiService: LSFourSquareAPIService.Type!
                    
                    beforeEach {
                        locationManager = LSLocationManager()
                        apiService = LSFourSquareAPIService.self
                        viewModel = FindLunchSpotViewModel(view: view, locationManager: locationManager, apiService: apiService)
                    }
                    
                    it("should have initialized the view, locationManager, and apiService properties") {
                        expect(viewModel.view).to(beIdenticalTo(view))
                        expect(viewModel.locationManager).to(beIdenticalTo(locationManager))
                        expect(viewModel.apiService).to(beIdenticalTo(apiService))
                    }
                }
            }
            
            describe("Location Manager did update placemark") {
                
                let updatedCurrentPlacemark = CLPlacemark()
                
                context("when a placemark is already currently being displayed") {
                    
                    beforeEach {
                        viewModel.currentDisplayPlacemark = CLPlacemark()
                        viewModel.locationManager(viewModel.locationManager, didUpdatePlacemark: updatedCurrentPlacemark)
                    }
                    
                    it("should just update currentLocationPlacemark, but not the currentDisplayPlacemark") {
                        expect(viewModel.currentLocationPlacemark).to(beIdenticalTo(updatedCurrentPlacemark))
                        expect(viewModel.currentDisplayPlacemark).toNot(beIdenticalTo(updatedCurrentPlacemark))
                    }
                }
                
                context("when a placemark is not being displayed") {
                    
                    class FindLunchViewModelMock: FindLunchSpotViewModel {
                        
                        var updateLocationWasCalled = false
                        
                        override func updateLocationDelegate(withPlacemark placemark: CLPlacemark?, animated: Bool) {
                            self.updateLocationWasCalled = true
                        }
                    }
                    
                    var viewModelMock: FindLunchViewModelMock!
                    
                    beforeEach {
                        viewModelMock = FindLunchViewModelMock(view: view)
                        viewModelMock.currentLocationPlacemark = nil
                        viewModelMock.currentDisplayPlacemark = nil
                        viewModelMock.locationManager(viewModel.locationManager, didUpdatePlacemark: updatedCurrentPlacemark)
                    }
                    
                    it("should update both currentLocationPlacemark and currentDisplayPlacemark") {
                        expect(viewModelMock.currentLocationPlacemark).to(beIdenticalTo(updatedCurrentPlacemark))
                        expect(viewModelMock.currentDisplayPlacemark).to(beIdenticalTo(updatedCurrentPlacemark))
                        expect(viewModelMock.updateLocationWasCalled).to(beTrue())
                    }
                }
            }
            
            describe("Calculate Current Display Region") {
                
                context("when currentDisplayPlacemark is non-nil") {
                    
                    let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), addressDictionary: nil)
                    let span = MKCoordinateSpanMake(0.005, 0.005)
                    let expectedRegion = MKCoordinateRegionMake((placemark.location?.coordinate)!, span)
                    
                    beforeEach {
                        viewModel.currentDisplayPlacemark = placemark
                    }
                    
                    it("should return a non-nil region with coords matching that of currentDisplayPlacemark") {
                        let currentDisplayRegion = viewModel.currentDisplayRegion()
                        expect(currentDisplayRegion?.center.longitude) == expectedRegion.center.longitude
                        expect(currentDisplayRegion?.center.latitude) == expectedRegion.center.latitude
                        expect(currentDisplayRegion?.span.latitudeDelta) == expectedRegion.span.latitudeDelta
                        expect(currentDisplayRegion?.span.longitudeDelta) == expectedRegion.span.longitudeDelta
                    }
                }
                
                context("when currentDisplayPlacemark is nil") {
                    beforeEach {
                        viewModel.currentDisplayPlacemark = nil
                    }
                    
                    it("should return nil") {
                        let currentDisplayRegion = viewModel.currentDisplayRegion()
                        expect(currentDisplayRegion).to(beNil())
                    }
                }
            }
            
            describe("Finding Lunch Spot") {
                
                var viewMock: ViewMock!
                var wireframeMock: WireframeMock!
                
                beforeEach {
                    wireframeMock = viewModel.wireframe as! WireframeMock
                    viewMock = viewModel.view as! ViewMock
                }
                
                context("currentDisplayPlacemark is non-nil") {
                    
                    beforeEach {
                        viewModel.currentDisplayPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(1.0, 1.0), addressDictionary: nil)
                    }
                    
                    it("should present lunch spot details view") {
                        viewModel.findLunchSpotButtonPressed()
                        expect(wireframeMock.didPresentLunchDetailsView).to(beTrue())
                        expect(viewMock.lunchSpotWasFound).to(beTrue())
                    }
                }
                
                context("currentDisplayPlacemark is nil") {
                    beforeEach {
                        viewModel.currentDisplayPlacemark = nil
                    }
                    
                    it("it should not present lunch spot details view") {
                        viewModel.findLunchSpotButtonPressed()
                        expect(wireframeMock.didPresentLunchDetailsView).to(beFalse())
                        expect(viewMock.lunchSpotWasFound).to(beFalse())
                    }
                }
            }
        }
    }
    
}
