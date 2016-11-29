//
//  STSocialService.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 31/10/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

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
    var appID: String
    var appSecret: String
    var callbackURI: String?
    
    /// Storing the user id in the keychain
    var userId:String? {
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
    var token: String? {
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
    
    var refreshToken: String? {
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
    public init(appID: String, appSecret: String, appType: STSocialType, callbackURI: String? = nil) {
        self.appID = appID
        self.appSecret = appSecret
        self.appType = appType
        self.callbackURI = callbackURI
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
