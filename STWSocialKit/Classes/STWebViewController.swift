//
//  WebViewController.swift
//  StanwoodSocial
//
//  Copyright (c) 2018 stanwood GmbH
<<<<<<< Updated upstream
=======
//  Distributed under MIT licence.
>>>>>>> Stashed changes
//
//  The MIT License (MIT)
//
//  Copyright (c) 2018 Stanwood GmbH (www.stanwood.io)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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


