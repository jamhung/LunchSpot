//
//  LunchMenuViewController.swift
//  LunchSpot
//
//  Created by James Hung on 2/29/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

import UIKit

@objc(LunchMenuViewController)
class LunchMenuViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var menuURL: NSURL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Menu"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: Selector("doneButtonPressed"))
        
        if let menuURL = self.menuURL {
            let urlRequest = NSURLRequest(URL: menuURL)
            self.webView.loadRequest(urlRequest)
            self.webView.delegate = self
        }
    }
    
    func doneButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension LunchMenuViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        self.activityIndicator.stopAnimating()
    }
}