//
//  ThumbnailCollectionViewCell.swift
//  LunchSpot
//
//  Created by James Hung on 3/13/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import SDWebImage

class ThumbnailCollectionViewCell: UICollectionViewCell {
    
    static let nibName = "ThumbnailCollectionViewCell"
    static let reuseIdentifier = "ThumbnailCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(hexString: "EEEEEE")
    }
    
    func configure(withImageURL imageURL: NSURL) {
        self.imageView.sd_setImageWithURL(imageURL, completed: nil)
    }
}
