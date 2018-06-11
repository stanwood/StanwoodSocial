//
//  FBLike.swift
//  StanwoodSocial
//
//  Copyright (c) 2018 stanwood GmbH
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
import ObjectMapper

private enum FBLikeKey:String {
    case total_count
    case can_like
    case has_liked
    case summary
}

private enum YTLikeKey:String {
    case items
    case rating
    case statistics
    case likeCount
}

private enum IGLikeKey:String {
    case data
    case id
    case hasLiked = "user_has_liked"
    case likes
    case count
    case link
}

private enum ShareBaseURL: String {
    case facebook = "https://www.facebook.com/%@"
    case youtube = "https://www.youtube.com/watch?v=%@"
}

public struct STLike {
    public var count: Int?
    public var hasLiked: Bool?
    public var canLike: Bool?
    public var id:String?
    public var shareLink:String?
    public var countString:String {
        get {
            if let _count = count {
                return _count >= 1000 ? "Likes \(Double(Double(_count) / 1000).roundTo(places: 2))k" : "Likes \(_count)"
            } else {
                return ""
            }
        }
    }
    
    fileprivate var items:[Any]?
    fileprivate var itemsDictionary: [String:Any]?
    fileprivate var ratingKey:String?
    fileprivate var likeCount:String?
    
    // MARK: Facebook
    init(facebookMap map: Map, id: String? = nil) {
        count <- map[FBLikeKey.total_count.rawValue]
        hasLiked <- map[FBLikeKey.has_liked.rawValue]
        canLike <- map[FBLikeKey.can_like.rawValue]
        self.id = id
        
        shareLink = String(format: ShareBaseURL.facebook.rawValue, id ?? "")
    }
    
    // MARK: Instagram
    init(instagramMap map: Map) {
        itemsDictionary <- map[IGLikeKey.data.rawValue]
        canLike = true
        
        let dataMap = Map(mappingType: .fromJSON, JSON: itemsDictionary ?? [:])
        id <- dataMap[IGLikeKey.id.rawValue]
        hasLiked <- dataMap[IGLikeKey.hasLiked.rawValue]
        shareLink <- dataMap[IGLikeKey.link.rawValue]
        itemsDictionary <- dataMap[IGLikeKey.likes.rawValue]
        
        if let _count = itemsDictionary?[IGLikeKey.count.rawValue] as? Int {
            self.count = _count
        }
    }
    
    // MARK: YouTube
    init(youtubeMap map: Map, id: String? = nil, userId: String? = nil) {
        items <- map[YTLikeKey.items.rawValue]
        itemsDictionary <- map[YTLikeKey.statistics.rawValue]
        self.id = id
        
        shareLink = String(format: ShareBaseURL.youtube.rawValue, id ?? "")
        
        //Setting YouTube like object
        if let _items = items, var _statistics = itemsDictionary {
            
            for item in _items {
                if let _itemDic = item as? [String:Any] {
                    for (key, value) in _itemDic {
                        _statistics.updateValue(value, forKey: key)
                    }
                }
            }
            
            let ytMap = Map(mappingType: .fromJSON, JSON: _statistics)
            
            ratingKey <- ytMap[YTLikeKey.rating.rawValue]
            hasLiked = isLiked(key: ratingKey ?? "")
            canLike = true
            likeCount <- ytMap[YTLikeKey.likeCount.rawValue]
            count = Int(likeCount ?? "")
        }
    }
    
    fileprivate func isLiked(key: String) -> Bool {
        switch key {
        case "like":
            return true
        default:
            return false
        }
    }
}
