//
//  STComment.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 14/11/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import Foundation
import ObjectMapper

enum STCommentKey: String {
    case count = "total_count"
    case canComment = "can_comment"
}

struct STComment {
    var count:Int?
    var canComment:Bool?
    var id:String
    
    init(map:Map, id:String) {
        self.id = id
        count <- map[STCommentKey.count.rawValue]
        canComment <- map[STCommentKey.canComment.rawValue]
    }
}
