//
//  TipsHeaderView.swift
//  LunchSpot
//
//  Created by James Hung on 3/8/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit

class TipsHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var bottomDividerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomDividerLine: UIView!
    @IBOutlet weak var topDividerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topDividerLine: UIView!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        let headerView = NSBundle.mainBundle().loadNibNamed("TipsHeaderView", owner: self, options: nil).first as! UIView
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = NSLayoutConstraint(item: headerView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: headerView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: headerView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: headerView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0)
        
        self.addSubview(headerView)
        self.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        
        self.headerLabel.textColor = UIColor(hexString: "727272")
        self.bottomDividerHeightConstraint.constant = 0.5
        self.topDividerHeightConstraint.constant = 0.5
        self.bottomDividerLine.backgroundColor = UIColor(hexString: "B6B6B6")
        self.topDividerLine.backgroundColor = UIColor(hexString: "B6B6B6")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
