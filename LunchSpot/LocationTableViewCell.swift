//
//  LocationTableViewCell.swift
//  LunchSpot
//
//  Created by James Hung on 3/13/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    static let nibName = "LocationTableViewCell"
    static let reuseIdentifier = "LocationTableViewCell"
    
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.textColor = UIColor(hexString: "727272")
        self.subtitleLabel.textColor = UIColor(hexString: "B6B6B6")
    }

    func configure(withTitle title: String?, subtitle: String?) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }
}
