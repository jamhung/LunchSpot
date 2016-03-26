//
//  LunchDetailsViewController.swift
//  LunchSpot
//
//  Created by James Hung on 2/22/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import MapKit
import NYTPhotoViewer

extension UINavigationController {
    func themeNavigationBar(withImage themeImage: UIImage, showKeyline: Bool) {
        let themeColors = NSArray(ofColorsFromImage: themeImage, withFlatScheme: true)
        let navBarBackgroundColor = themeColors[4] as! UIColor
        let navBarTintColor = UIColor(contrastingBlackOrWhiteColorOn: navBarBackgroundColor, isFlat: true, alpha: 0.95)
        
        self.navigationBar.barTintColor = navBarBackgroundColor
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationBarHidden = false
        self.navigationBar.translucent = false
        self.navigationBar.tintColor = navBarTintColor
        
        if showKeyline == false {
            self.navigationBar.shadowImage = UIImage()
        }
        
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: navBarTintColor,
            NSFontAttributeName: UIFont(name: "Avenir-Book", size: 21)!
        ]
    }
}

@objc(LunchDetailsViewController)
class LunchDetailsViewController: UIViewController {
    let headerViewHeight: CGFloat = 342.0
    
    @IBOutlet weak var tipsTableView: UITableView!
    
    var viewModel: LunchDetailsViewModelProtocol!
    
    private var lunchDetailsHeaderView: LunchDetailsHeaderView!
    private var lastContentOffsetY: CGFloat = 0.0
    private var headerBackgroundColor = UIColor.clearColor()
    private var navTitleTransition: CATransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.configureTipsTableView()
        self.viewModel.viewLoaded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        
        let contrastColor = self.navigationController?.navigationBar.tintColor
        self.view.backgroundColor = self.navigationController?.navigationBar.barTintColor
        
        if let tintColor = contrastColor where tintColor.isBright() {
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        } else {
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Configure table view header
        
        if self.lunchDetailsHeaderView == nil {
            let headerView = UIView(frame: CGRectMake(0, 0, 375, LunchDetailsHeaderView.defaultHeight))
            
            self.lunchDetailsHeaderView = NSBundle.mainBundle().loadNibNamed("LunchDetailsHeaderView", owner: nil, options: nil).first as! LunchDetailsHeaderView
            self.lunchDetailsHeaderView.delegate = self
            
            self.lunchDetailsHeaderView.configure(withVenue: self.viewModel.venueData(), venueImage: self.viewModel.headerImage())
            self.lunchDetailsHeaderView.translatesAutoresizingMaskIntoConstraints = false
            
            let contrastColor = self.navigationController?.navigationBar.tintColor
            let backgroundColor = self.navigationController?.navigationBar.barTintColor
            
            self.lunchDetailsHeaderView.setBackgroundViewColor(backgroundColor)
            self.lunchDetailsHeaderView.setTextColor(contrastColor)
            
            let topConstraint = NSLayoutConstraint(item: self.lunchDetailsHeaderView, attribute: .Top, relatedBy: .Equal, toItem: headerView, attribute: .Top, multiplier: 1.0, constant: 0)
            
            let bottomConstraint = NSLayoutConstraint(item: self.lunchDetailsHeaderView, attribute: .Bottom, relatedBy: .Equal, toItem: headerView, attribute: .Bottom, multiplier: 1.0, constant: 0)
            
            let leadingConstraint = NSLayoutConstraint(item: self.lunchDetailsHeaderView, attribute: .Leading, relatedBy: .Equal, toItem: headerView, attribute: .Leading, multiplier: 1.0, constant: 0)
            
            let trailingConstraint = NSLayoutConstraint(item: self.lunchDetailsHeaderView, attribute: .Trailing, relatedBy: .Equal, toItem: headerView, attribute: .Trailing, multiplier: 1.0, constant: 0)
            
            headerView.addSubview(self.lunchDetailsHeaderView)
            headerView.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
            
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            
            self.tipsTableView.tableHeaderView = headerView
        }

    }
}


// MARK: View Configuration Methods
extension LunchDetailsViewController {
    
    func configureTipsTableView() {
        self.tipsTableView.registerNib(UINib(nibName: TipTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: TipTableViewCell.reuseIdentifier)
        self.tipsTableView.registerNib(UINib(nibName: PhotoSetTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PhotoSetTableViewCell.reuseIdentifier)
        
        self.tipsTableView.registerClass(TipsHeaderView.self, forHeaderFooterViewReuseIdentifier: "TipsHeaderView")
        
        self.tipsTableView.showsVerticalScrollIndicator = false
        self.tipsTableView.allowsSelection = false
        self.tipsTableView.estimatedRowHeight = 85.0
        self.tipsTableView.rowHeight = UITableViewAutomaticDimension
        self.tipsTableView.separatorInset = UIEdgeInsetsMake(0, 65, 0, 0)
        self.tipsTableView.separatorColor = UIColor(hexString: "B6B6B6")
        self.tipsTableView.tableFooterView = UIView()
    }
}

extension LunchDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        self.lastContentOffsetY = contentOffsetY
        
        self.lunchDetailsHeaderView.contentViewTopConstraint.constant = max(contentOffsetY, 0)
        self.lunchDetailsHeaderView.contentViewBottomConstraint.constant = min(-contentOffsetY, 0)
        
        if contentOffsetY < 0 {
            self.tipsTableView.backgroundColor = self.headerBackgroundColor
        } else {
            self.tipsTableView.backgroundColor = UIColor.whiteColor()
        }
        
        if self.navTitleTransition != nil {
            return
        }
        
        if contentOffsetY > 90 {
            if self.navigationItem.title == nil || self.navigationItem.title?.characters.count == 0 {
                
                self.navTitleTransition = CATransition()
                self.navTitleTransition!.duration = 0.2
                self.navTitleTransition!.type = kCATransitionFade
                self.navTitleTransition!.delegate = self
                self.navigationController?.navigationBar.layer.addAnimation(self.navTitleTransition!, forKey: "fadeTextIn")
                self.navigationItem.title = self.viewModel.venueName()
            }
        } else if self.navigationItem.title?.characters.count > 0 {
            self.navTitleTransition = CATransition()
            self.navTitleTransition!.duration = 0.2
            self.navTitleTransition!.type = kCATransitionFade
            self.navTitleTransition!.delegate = self
            self.navigationController?.navigationBar.layer.addAnimation(self.navTitleTransition!, forKey: "fadeTextOut")
            self.navigationItem.title = ""
        }
    }
}

// MARK: Core Animation Delegate Methods
extension LunchDetailsViewController {
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.navTitleTransition = nil
    }
}

// MARK: UITableView Delegate Methods
extension LunchDetailsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("TipsHeaderView") as! TipsHeaderView
        
        if section == 0 {
            headerView.headerLabel.text = "Photos"
        } else {
            headerView.headerLabel.text = "What people are saying..."
        }
        return headerView
    }
}

// MARK: UITableView Data Source Methods
extension LunchDetailsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var sectionCount = 0
        if self.viewModel.numberOfTips() > 0 {
            sectionCount++
        }
        
        if self.viewModel.numberOfPhotos() > 0 {
            sectionCount++
        }
        
        return sectionCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.viewModel.numberOfTips()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(PhotoSetTableViewCell.reuseIdentifier) as! PhotoSetTableViewCell
            cell.delegate = self
            cell.configure(withPhotoSet: self.viewModel.photoSet())
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TipTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! TipTableViewCell
            
            let tip = self.viewModel.tipAtIndex(indexPath.row)
            cell.configure(withTipJSON: tip)
            return cell
        }
    }
}

extension LunchDetailsViewController: PhotoSetTableViewCellDelegate {
    func cellTapped(view: UIView, photo: NYTPhoto) {
        let photoViewController = NYTPhotosViewController(photos: [photo])
        photoViewController.overlayView?.captionView = nil
        self.presentViewController(photoViewController, animated: true, completion: nil)
    }
}

extension LunchDetailsViewController: LunchDetailsViewProtocol {
    func refreshTips() {
        self.tipsTableView.reloadData()
    }
    
    func refreshPhotos() {
        self.tipsTableView.reloadData()
    }
}

// MARK: LunchDetailsHeaderView Delegate Methods
extension LunchDetailsViewController: LunchDetailsHeaderViewDelegate {
    func callButtonPressed() {
        self.viewModel.callButtonPressed()
    }
    
    func mapButtonPressed() {
        self.viewModel.mapButtonPressed()
    }
    
    func menuButtonPressed() {
        self.viewModel.menuButtonPressed()
    }
}