//
//  SMAuthor.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 31/08/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import Foundation
import ObjectMapper

struct SMAuthor {
    var url:String!
    var imageUrl:String!
    var name:String!
    
    init(map:Map){
        url <- map[PostKey.url.rawValue]
        imageUrl <- map[PostKey.image_url.rawValue]
        name <- map[PostKey.name.rawValue]
    }
}