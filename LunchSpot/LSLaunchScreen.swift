//
//  LSLaunchScreen.swift
//  LunchSpot
//
//  Created by James Hung on 3/16/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit

class LSLaunchScreen: UIView {

    @IBOutlet weak var logoImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        let view = NSBundle.mainBundle().loadNibNamed("LSLaunchScreen", owner: self, options: nil).first as! UIView
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
        
        let leadingConstraint = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0)
        
        let trailingConstraint = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0)
        
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
        
        self.addSubview(view)
        self.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    
    func startLoadingAnimation() {
        
    }
}
