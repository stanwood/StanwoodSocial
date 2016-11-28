//
//  STSocialConfiguration.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 15/11/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import Foundation
import FBSDKLoginKit

public struct STSocialConfiguration {
    var services:[STSocialService]
    
    public func logout(){
        for service in services {
            logout(service: service)
        }
    }
    
    /*
     Loging out the user
     */
    func logout(service: STSocialService){
        switch service.appType {
        case .facebook:
            let manager = FBSDKLoginManager()
            manager.logOut()
            FBSDKAccessToken.setCurrent(nil)
            break
        case .youtube, .instagram:
            service.logout()
        }
    }
    
    /*
     Setting service user id
     */
    mutating func set(userId id: String, forServiceType type: STSocialType) {
        for (index, service) in services.enumerated() {
            if service.appType == type {
                service.userId = id
                services.remove(at: index)
                services.append(service)
            }
        }
    }
}
