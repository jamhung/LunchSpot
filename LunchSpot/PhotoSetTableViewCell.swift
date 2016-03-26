//
//  PhotoSetTableViewCell.swift
//  LunchSpot
//
//  Created by James Hung on 3/13/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import SwiftyJSON
import NYTPhotoViewer

protocol PhotoSetTableViewCellDelegate {
    func cellTapped(view: UIView, photo: NYTPhoto)
}

class PhotoSetTableViewCell: UITableViewCell {
    
    static let nibName = "PhotoSetTableViewCell"
    static let reuseIdentifier = "PhotoSetTableViewCell"
    
    var photoSet = [JSON]()
    var delegate: PhotoSetTableViewCellDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCollectionView()
    }
    
    func setupCollectionView() {
        self.collectionView.alwaysBounceHorizontal = true
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.registerNib(UINib(nibName: ThumbnailCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: ThumbnailCollectionViewCell.reuseIdentifier)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .Horizontal
        flowLayout.itemSize = CGSizeMake(100, 100)
    }
    
    func configure(withPhotoSet photoSet: [JSON]) {
        self.photoSet = photoSet
        self.collectionView.reloadData()
    }
}

extension PhotoSetTableViewCell: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoSet.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ThumbnailCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! ThumbnailCollectionViewCell
        
        cell.layer.cornerRadius = 5.0
        cell.clipsToBounds = true
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor(hexString: "B6B6B6").CGColor
        
        let photoJSON = self.photoSet[indexPath.row]
        let photoURLPrefix = photoJSON["prefix"].stringValue
        let photoURLSuffix = photoJSON["suffix"].stringValue
        let photoURLString = "\(photoURLPrefix)500x500\(photoURLSuffix)"
        
        if let photoURL = NSURL(string: photoURLString) {
            cell.configure(withImageURL: photoURL)
        }
        return cell
    }
}

extension PhotoSetTableViewCell: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! ThumbnailCollectionViewCell
        let thumbnailPhoto = ThumbnailPhoto(image: selectedCell.imageView.image, imageData: nil, attributedCaptionTitle: nil)
        
        self.delegate?.cellTapped(selectedCell.imageView, photo: thumbnailPhoto)
    }
}

extension PhotoSetTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
}
