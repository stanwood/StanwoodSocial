//
//  AppDelegate.swift
//  STWSocialKit
//
//  Created by Tal Zion on 11/28/2016.
//  Copyright (c) 2016 Tal Zion. All rights reserved.
//

import UIKit
import STWSocialKit

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

