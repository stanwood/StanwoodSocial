//
//  STAccount.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 15/11/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import Foundation
import Locksmith

struct STAccount: ReadableSecureStorable, GenericPasswordSecureStorable, CreateableSecureStorable, DeleteableSecureStorable {
    
    var service: String
    var account: String
    var data: [String : Any]
}
