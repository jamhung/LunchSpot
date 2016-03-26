//
//  LunchMapViewController.swift
//  LunchSpot
//
//  Created by James Hung on 2/29/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import MapKit

@objc(LunchMapViewController)
class LunchMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var lunchSpotCoordinate: CLLocationCoordinate2D!
    var venueName: String!
    
    init(centerCoordinate: CLLocationCoordinate2D, venueName: String) {
        self.lunchSpotCoordinate = centerCoordinate
        self.venueName = venueName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Map"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: Selector("doneButtonPressed"))
        
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(self.lunchSpotCoordinate, span)
        self.mapView.region = region
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = self.lunchSpotCoordinate
        pointAnnotation.title = self.venueName
        self.mapView.addAnnotation(pointAnnotation)
        
        self.mapView.showsUserLocation = true
    }
    
    func doneButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

//extension LunchMapViewController: MKMapViewDelegate {
//    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("")
//    }
//}
