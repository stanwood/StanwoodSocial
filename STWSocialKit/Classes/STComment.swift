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

public struct STComment {
    public var count:Int?
    public var canComment:Bool?
    public var id:String
    
    public init(map:Map, id:String) {
        self.id = id
        count <- map[STCommentKey.count.rawValue]
        canComment <- map[STCommentKey.canComment.rawValue]
    }
}
