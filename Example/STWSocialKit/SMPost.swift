//
//  SMPost.swift
//  StanwoodSocial
//
//  Copyright (c) 2018 stanwood GmbH
//  Distributed under MIT licence.
//

import Foundation
import ObjectMapper

enum PostType:String {
    case facebook
    case youtube
    case instagram
    
    static let allValues = [facebook, youtube, instagram]
}

enum PostKey: String {
    case author
    case text
    case url
    case name
    case image_url
    case image
    case title
    case video
    case order
    case created_time
    case type
    case id
    case key
}

struct SMPost: Type {
    var author:SMAuthor!
    var text:String!
    var image:String!
    var title:String!
    var video:String!
    var order:Double!
    var key:String!
    var createdAt:Date!
    var type:PostType!
    var id:String!
    
    var postedAt:String {
        get {
            let calander = Calendar.current
            let unit = Set<Calendar.Component>([.minute, .hour, .day, .weekOfYear, .month])
            let components = calander.dateComponents(unit, from: createdAt, to: Date())
            return getPostAtString(fromComponant: components)
        }
    }
    
    fileprivate var authurDictionary:[String:AnyObject]!
    fileprivate var stringType:String!
    fileprivate var stringCreatedAt:String!
    
    init(map:Map) {
        authurDictionary <- map[PostKey.author.rawValue]
        text <- map[PostKey.text.rawValue]
        image <- map[PostKey.image.rawValue]
        title <- map[PostKey.title.rawValue]
        video <- map[PostKey.video.rawValue]
        order <- map[PostKey.order.rawValue]
        key <- map[PostKey.key.rawValue]
        stringType <- map[PostKey.type.rawValue]
        id <- map[PostKey.id.rawValue]
        stringCreatedAt <- map[PostKey.created_time.rawValue]
        
        
        if let atDate = stringCreatedAt, getCreatedAt(createAt: atDate) != nil {
            createdAt = getCreatedAt(createAt: atDate)!
        }
        
        let map = Map(mappingType: .fromJSON, JSON: authurDictionary)
        author = SMAuthor(map: map)
        
        type = PostType(rawValue: stringType)
    }
    
    fileprivate func getCreatedAt(createAt at:String) -> Date? {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        let date = dateFormatter.date(from: at)
        return date
    }
    
    fileprivate func getPostAtString(fromComponant component: DateComponents) -> String {
        if component.month != 0 {
            return component.month! > 1 ?  String(format: "%@ months ago", "\(component.month!)") : String(format: "%@ month ago", "\(component.month!)")
            
        } else if component.weekOfYear != 0 {
            return component.weekOfYear! > 1 ?  String(format: "%@ weeks ago", "\(component.weekOfYear!)") : String(format: "%@ week ago", "\(component.weekOfYear!)")
            
        } else if component.day != 0 {
            return component.day! > 1 ?  String(format: "%@ days ago", "\(component.day!)") : String(format: "%@ day ago", "\(component.day!)")
            
        } else if component.hour != 0 {
            return component.hour! > 1 ?  String(format: "%@ hours ago", "\(component.hour!)") : String(format: "%@ hour ago", "\(component.hour!)")
            
        } else if component.minute != 0 {
            return component.minute! > 1 ?  String(format: "%@ minutes ago", "\(component.minute!)") : String(format: "%@ minute ago", "\(component.minute!)")
            
        } else {
            return ""
        }
    }
}
