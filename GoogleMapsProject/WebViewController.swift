//
//  WebViewController.swift
//  GoogleMapsProject
//
//  Created by Miguel Tepale on 6/5/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import Foundation
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var userUrl: String!
    var currentWebView: WKWebView!
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: userUrl) else {
            print("url value is nil")
            return
        }
        
        let request = URLRequest(url: url)
        currentWebView = WKWebView(frame: self.view.frame)
        currentWebView.load(request)
        self.view.addSubview(currentWebView)
    }
}
