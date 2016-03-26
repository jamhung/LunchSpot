//
//  LunchDetailsViewModelSpec.swift
//  LunchSpot
//
//  Created by James Hung on 3/20/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import Quick
import Nimble
import SwiftyJSON
@testable import LunchSpot

class LunchDetailsViewModelSpec: QuickSpec {
    
    override func spec() {
        
        describe("LunchDetailsViewModel") {
            
            var viewModel: LunchDetailsViewModel!
            let themeImage = UIImage()
            var venueJSON: JSON!
            
            beforeEach {
                let venueDict = ["name": "test venue"]
                venueJSON = JSON(venueDict)
                viewModel = LunchDetailsViewModel(venueJSON: venueJSON, themeImage: themeImage)
            }
            
            describe("Initialization") {
                
                context("when initialized without passing in an apiService object") {
                    it("should have the default apiService object set") {
                        expect(viewModel.themeImage).to(beIdenticalTo(themeImage))
                        expect(viewModel.apiService).toNot(beNil())
                    }
                }
                
                context("when initialized by passing in an apiService object") {
                    var apiService: LSFourSquareAPIService.Type!
                    
                    beforeEach {
                        apiService = LSFourSquareAPIService.self
                        viewModel = LunchDetailsViewModel(venueJSON: venueJSON, themeImage: themeImage, apiService: apiService)
                    }
                    
                    it("should set the apiService with the passed in object") {
                        expect(viewModel.themeImage).to(beIdenticalTo(themeImage))
                        expect(viewModel.apiService).to(beIdenticalTo(apiService))
                    }
                }
            }
        }
    }
}
