//
//  STSocialService.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 31/10/2016.
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

import Foundation
import Locksmith
/**
 STSocialServiceProtocol Defines the service properties
 */
protocol STSocialServiceProtocol {
    var appType: STSocialType { get }
    var appID:String { get }
    var appSecret: String { get }
    
    var token: String? { get set }
}

/**
 STSocialType sets the OAuth service
 */
public enum STSocialType: String {
    case facebook
    case youtube
    case instagram
}

/**
 
 */
public class STSocialService: STSocialServiceProtocol {
    
    var appType: STSocialType
    open var appID: String
    open var appSecret: String
    var callbackURI: String?
    var authRequired:Bool
    
    /// Storing the user id in the keychain
    open var userId:String? {
        get {
            if let dictionary = Locksmith.loadDataForUserAccount(userAccount: "user_id\(appType.rawValue)") {
                return dictionary["user_id_\(appID)"] as? String
            } else {
                return nil
            }
        }
        
        set (newValue) {
            do {
                if userId == nil {
                    try Locksmith.updateData(data: ["user_id_\(appID)": newValue as Any], forUserAccount: "user_id\(appType.rawValue)")
                } else {
                    try Locksmith.saveData(data: ["user_id_\(appID)": newValue as Any], forUserAccount: "user_id\(appType.rawValue)")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    //Storing the access token in the keychain
    open var token: String? {
        get {
            if let dictionary = Locksmith.loadDataForUserAccount(userAccount: appType.rawValue) {
                return dictionary["token_\(appID)"] as? String
            } else {
                return nil
            }
        }
        
        set (newValue) {
            do {
                if token == nil {
                    try Locksmith.updateData(data: ["token_\(appID)": newValue as Any], forUserAccount: appType.rawValue)
                } else {
                    try Locksmith.saveData(data: ["token_\(appID)": newValue as Any], forUserAccount: appType.rawValue)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    open var refreshToken: String? {
        get {
            if let dictionary = Locksmith.loadDataForUserAccount(userAccount: "refreshToken_\(appType.rawValue)") {
                return dictionary["refreshToken_\(appID)"] as? String
            } else {
                return nil
            }
        }
        
        set (newValue) {
            do {
                if refreshToken == nil {
                    try Locksmith.updateData(data: ["refreshToken_\(appID)": newValue as Any], forUserAccount: "refreshToken_\(appType.rawValue)")
                } else {
                    try Locksmith.saveData(data: ["refreshToken_\(appID)": newValue as Any], forUserAccount: "refreshToken_\(appType.rawValue)")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: Init
    public init(appID: String, appSecret: String, appType: STSocialType, callbackURI: String? = nil, authRequired: Bool = true) {
        self.appID = appID
        self.appSecret = appSecret
        self.appType = appType
        self.callbackURI = callbackURI
        self.authRequired = authRequired
    }
    
    // MARK: Logout
    
    public func logout(){
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: appType.rawValue)
            try Locksmith.deleteDataForUserAccount(userAccount: "refreshToken_\(appType.rawValue)")
            try Locksmith.deleteDataForUserAccount(userAccount: "user_id\(appType.rawValue)")
        } catch {
            print(error.localizedDescription)
        }
    }
}
