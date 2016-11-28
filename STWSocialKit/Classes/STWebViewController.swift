//
//  WebViewController.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 16/11/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import OAuthSwift
import UIKit
typealias WebView = UIWebView // WKWebView


class STWebViewController: OAuthWebViewController {
    
    var targetURL: URL?
    let webView: WebView = WebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.frame = UIScreen.main.bounds
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        self.view.addSubview(self.webView)
        loadAddressURL()
    }
    
    override func handle(_ url: URL) {
        targetURL = url
        super.handle(url)
        self.loadAddressURL()
    }
    
    func loadAddressURL() {
        guard let url = targetURL else {
            return
        }
        let req = URLRequest(url: url)
        self.webView.loadRequest(req)
        
    }
}

// MARK: delegate

extension STWebViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.url, url.scheme == "oauth-swift" || url.absoluteString.contains("#access_token=") {
            
            // Call here AppDelegate.sharedInstance.applicationHandleOpenURL(url) if necessary ie. if AppDelegate not configured to handle URL scheme
            // compare the url with your own custom provided one in `authorizeWithCallbackURL`
            if let appDelegate = UIApplication.shared.delegate { // as? AppDelegate {
                
                /// Checking which OS to execute the url handler delegate
                if #available(iOS 9, *) {
                    _ = appDelegate.application!(UIApplication.shared, open: url, options: [:])
                } else {
                    _ = appDelegate.application!(UIApplication.shared, open: url, sourceApplication: nil, annotation: UIApplicationOpenURLOptionsKey.annotation)
                }
            }
            
            self.dismissWebViewController()
        }
        return true
    }
}


