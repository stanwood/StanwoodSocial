//
//  AppDelegate.swift
//  StanwoodSocial
//
//  Created by Tal Zion on 11/28/2016.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2018 stanwood GmbH
//
//  Distributed under MIT licence.
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

import UIKit
import StanwoodSocial

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Facebook
        STSocialManager.configure(application: application, didFinishLaunchingWithOptions: launchOptions)
        
        /// Configuring Interactive Social Stream
        let facebook = STSocialService(appID: SocialConstants.fbAppID, appSecret: SocialConstants.fbAppSecret, appType: .facebook)
        let instagram = STSocialService(appID: SocialConstants.igAppID, appSecret: SocialConstants.igAppSecret, appType: .instagram, callbackURI: "https://www.sophia-thiel.com", authRequired: false)
        let youtube = STSocialService(appID: SocialConstants.ytAppID, appSecret: SocialConstants.ytAppSecret, appType: .youtube, callbackURI: "\(Bundle.main.bundleIdentifier ?? ""):/oauth2Callback")
        
        let configurations = STSocialConfiguration(services: [facebook, instagram, youtube])
        
        _ = STSocialManager.shared.set(configurations: configurations)
        STSocialManager.shared.isDynamicLogin = false
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        STSocialManager.handle(callbackURL: url)
        return STSocialManager.configure(app: app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        STSocialManager.handle(callbackURL: url)
        return true
    }
}

