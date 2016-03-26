//
//  LunchDetailsHeaderView.swift
//  LunchSpot
//
//  Created by James Hung on 2/28/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework

protocol LunchDetailsHeaderViewDelegate {
    func callButtonPressed() -> Void
    func menuButtonPressed() -> Void
    func mapButtonPressed() -> Void
}


class LunchDetailsHeaderView: UIView {
    static let nibName = "LunchDetailsHeaderView"
    static let reuseIdentifier = "LunchDetailsHeaderView"
    static let defaultHeight: CGFloat = 342.0
    
    @IBOutlet weak var venueAvatarImageView: UIImageView!
    @IBOutlet weak var venueAddressLabel: UILabel!
    @IBOutlet weak var venueTitleLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarTopConstraint: NSLayoutConstraint!
    var delegate: LunchDetailsHeaderViewDelegate?
    
    var venue: JSON!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupButtons()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.venueTitleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.venueTitleLabel.bounds)
        self.venueAddressLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.venueAddressLabel.bounds)
    }
    
    func setupButtons() {
        let mapImage = UIImage(named: "Map Button")?.imageWithRenderingMode(.AlwaysTemplate)
        self.mapButton.setImage(mapImage, forState: .Normal)
        
        let menuImage = UIImage(named: "Menu Button")?.imageWithRenderingMode(.AlwaysTemplate)
        self.menuButton.setImage(menuImage, forState: .Normal)
        
        let callImage = UIImage(named: "Call Button")?.imageWithRenderingMode(.AlwaysTemplate)
        self.callButton.setImage(callImage, forState: .Normal)
    }
    
    func configure(withVenue venue: JSON, venueImage: UIImage) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.venue = venue
        self.configureVenueAvatar(withImage: venueImage)
        self.configureVenueTitleLabel()
        self.configureVenueAddressLabel()
    }
    
    func configureVenueAvatar(withImage image: UIImage) {
        self.venueAvatarImageView.layer.borderWidth = 0.5
        self.venueAvatarImageView.layer.cornerRadius = CGRectGetWidth(self.venueAvatarImageView.frame)/2.0
        self.venueAvatarImageView.clipsToBounds = true
        self.venueAvatarImageView.image = image
    }
    
    func configureVenueTitleLabel() {
        self.venueTitleLabel.text = self.lunchSpotTitle()
    }
    
    func configureVenueAddressLabel() {
        self.venueAddressLabel.text = self.lunchSpotAddress()
    }
    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        self.delegate?.menuButtonPressed()
    }
    
    @IBAction func callButtonPressed(sender: AnyObject) {
        self.delegate?.callButtonPressed()
    }
    
    @IBAction func mapButtonPressed(sender: AnyObject) {
        self.delegate?.mapButtonPressed()
    }
    
    func setTextColor(color: UIColor?) {
        self.venueTitleLabel.textColor = color
        self.venueAddressLabel.textColor = color
        self.mapButton.tintColor = color
        self.menuButton.tintColor = color
        self.callButton.tintColor = color
    }
    
    func setBackgroundViewColor(color: UIColor?) {
        self.backgroundView.backgroundColor = color
        self.venueAvatarImageView.layer.borderColor = color?.darkenByPercentage(0.2).CGColor
    }
}

// MARK: Venue Data Helper Methods
extension LunchDetailsHeaderView {
    func lunchSpotTitle() -> String? {
        return self.venue["name"].string
    }
    
    func lunchSpotAddress() -> String? {
        let addressString = self.venue["location"]["address"].stringValue
        let cityString = self.venue["location"]["city"].stringValue
        return "\(addressString) \(cityString)"
    }
    
    func lunchSpotFeaturedPhotoURL() -> NSURL? {
        let featuredPhotoCount = self.venue["featuredPhotos"]["count"].intValue
        if featuredPhotoCount > 0 {
            let photoURLPrefix = self.venue["featuredPhotos"]["items"][0]["prefix"]
            let photoURLSuffix = self.venue["featuredPhotos"]["items"][0]["suffix"]
            let photoURLString = "\(photoURLPrefix)original\(photoURLSuffix)"
            return NSURL(string: photoURLString)
        }
        return nil
    }
}
