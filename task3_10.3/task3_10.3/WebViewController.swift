//
//  WebViewController.swift
//  task3_10.3
//
//  Created by Stanislav on 30/10/2019.
//  Copyright © 2019 Smikun Denis. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var url : String?
    var webView : WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = url else { return }
        let filtredURL = url.replacingOccurrences(of: " ", with: "_", options: .literal, range: nil)
        webView.load(URLRequest(url: NSURL(string: filtredURL)! as URL))
        
    }
}
