//
//  ThumbnailPhoto.swift
//  LunchSpot
//
//  Created by James Hung on 3/13/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class ThumbnailPhoto: NSObject, NYTPhoto {
    var image: UIImage?
    var imageData: NSData?
    var placeholderImage: UIImage?
    let attributedCaptionTitle: NSAttributedString?
    
    let attributedCaptionSummary: NSAttributedString? = NSAttributedString(string: "summary string", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
    
    let attributedCaptionCredit: NSAttributedString? = NSAttributedString(string: "credit", attributes: [NSForegroundColorAttributeName: UIColor.darkGrayColor()])
    
    init(image: UIImage? = nil, imageData: NSData? = nil, attributedCaptionTitle: NSAttributedString?) {
        self.image = image
        self.imageData = imageData
        self.attributedCaptionTitle = attributedCaptionTitle
        super.init()
    }
}
