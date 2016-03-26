//
//  TipTableViewCell.swift
//  LunchSpot
//
//  Created by James Hung on 2/29/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class TipTableViewCell: UITableViewCell {
    
    static let nibName = "TipTableViewCell"
    static let reuseIdentifier = "TipTableViewCell"
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarImageView.layer.cornerRadius = CGRectGetWidth(self.avatarImageView.frame)/2.0
        self.avatarImageView.layer.borderWidth = 0.5
        self.avatarImageView.layer.borderColor = UIColor(hexString: "B6B6B6").CGColor
        self.avatarImageView.clipsToBounds = true
        
        self.tipLabel.textColor = UIColor(hexString: "727272")
        self.authorLabel.textColor = UIColor(hexString: "B6B6B6")
        self.timeAgoLabel.textColor = UIColor(hexString: "B6B6B6")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tipLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.tipLabel.bounds)
    }
    
    func configure(withTipJSON tipJSON: JSON) {
        self.tipLabel.text = tipJSON["text"].string
        self.authorLabel.text = "\(tipJSON["user"]["firstName"].stringValue) \(tipJSON["user"]["lastName"].stringValue)"
        
        let timeAgo = tipJSON["createdAt"].doubleValue
        let timeAgoDate = NSDate(timeIntervalSince1970: timeAgo)
        let timeAgoString = timeAgoDate.timeAgoSinceNow()
        
        self.timeAgoLabel.text = timeAgoString
        
        let photoURLPrefix = tipJSON["user"]["photo"]["prefix"].stringValue
        let photoURLSuffix = tipJSON["user"]["photo"]["suffix"].stringValue
        
        let photoURLString = "\(photoURLPrefix)original\(photoURLSuffix)"
        
        let avatarPlaceholderImage = UIImage.ls_placeholderImageFromName(self.authorLabel.text, size: self.avatarImageView.frame.size, font: nil, circular: true)
        
        self.avatarImageView.sd_setImageWithURL(NSURL(string: photoURLString), placeholderImage: avatarPlaceholderImage)
    }
    
    
    
}
