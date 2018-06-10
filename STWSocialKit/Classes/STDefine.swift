//
//  STDefine.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 24/11/2016.
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

// MARK: - typealias blocks

public typealias STSuccessBlock = (_ success: Bool, _ error: Error?) -> Void
public typealias STLikeHandler = (_ likeObject: STLike?, _ error: Error?) -> Void
public typealias STCommentHandler = (_ likeObject: STComment?, _ error: Error?) -> Void

// MARK: - Social Constants

// Instagram
internal let kIGAuthorizeURL = "https://api.instagram.com/oauth/authorize"
internal let kIGLikeURL = "https://api.instagram.com/v1/media/%@/likes?access_token=%@"
internal let kIGMediaURL = "https://api.instagram.com/v1/media/%@/?access_token=%@"
internal let kIGCommentURL = "https://api.instagram.com/v1/media/%@/comments?access_token=%@"


// YouTube
internal let kYTAuthorizeURL = "https://accounts.google.com/o/oauth2/auth"
internal let kYTAccessTokenURL = "https://accounts.google.com/o/oauth2/token"
internal let kYTLikeURL = "https://www.googleapis.com/youtube/v3/videos/rate"
internal let kYTRatingURL = "https://www.googleapis.com/youtube/v3/videos/getRating"
internal let kYTStatisticsURL = "https://www.googleapis.com/youtube/v3/videos"
internal let kYTCommentURL = "https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&key=%@"

// MARK: Response Type

enum OAuthResponseType: String {
    case token
    case code
}

// MARK: - Social Paramaters

internal struct STParams {
    private init(){
    }
    
    // Facebook
    static var fbGetComment: [String: Any] {
        return [
            "summary":"true",
            "filter": "toplevel"
        ]
    }
    static func fbLike(forId id: String)-> [String: Any] {
        return [
            "id" : id,
            "rating" : "like"
        ]
    }
    
    static func fbUnlike(forId id: String)-> [String: Any] {
        return [
            "id" : id,
            "rating" : "none"
        ]
    }
    
    static func fb(comment: String) -> [String:Any] {
        return [
            "message": comment
        ]
    }
    
    // YouTube
    static func yt(comment: String, channel: String, id: String) -> [String:Any] {
        return [ "snippet":[
            "channelId" : channel,
            "videoId": id,
            "topLevelComment":[
                "snippet":[
                    "textOriginal": comment
                ]
            ]
            ]
        ]
    }
    static func ytOAuth() -> [String: Any] {
        return [
            "access_type" : "offline",
            "prompt" : "consent"
        ]
    }
    
    static func ytGetLike() -> [String: Any] {
        return ["summary":"true"]
    }
    
    static func ytId(forId id: String) -> [String: Any] {
        return [
            "id" : id
        ]
    }
    
    static func ytList(forId id: String) -> [String: Any] {
        return [
            "id" : id,
            "part" : "contentDetails, statistics"
        ]
    }
    
    // Instagram
    
    static func ig(comment: String) -> [String: Any] {
        return [
            "text" : comment
        ]
    }
}
/**
 STSocialScope defines the service scope and how to use the data
 */
enum STSocialScope: String {
    case read = "read"
    case write = "write"
    case account = "account"
    case likes = "likes"
    case comments = "comments"
    case publicContent = "public_content"
    case email = "email"
    case publicProfile = "public_profile"
    case userFriends = "user_friends"
    case publishActions = "publish_actions"
    case instagramScope = "likes+comments+public_content"
    case youtubeScope = "https://www.googleapis.com/auth/youtube https://www.googleapis.com/auth/youtube.force-ssl" 
    static let fbReadPermissions = [publicProfile.rawValue, email.rawValue, userFriends.rawValue]
    static let fbPublishPermissions = [publishActions.rawValue]
}

/// Sotial Operations

public enum STOperation {
    case like
    case comment
    case share
}

/// Configuration key

internal enum STConfigurationKey: String {
    case summary
    case data
}

/// ST error types

public enum OAuthErrorType: Error {
    case invalidConfiguration(String)
}

public enum STSocialError: Error {
    case shareError(String)
    case actionError(String)
    case likeError(String)
    case commentError(String)
}

internal enum STHTTPMethod: String {
    case DELETE
    case POST
    case GET
}

// STSocialErrorDomain
class STSocialErrorDomain {
    static let igAuthError = NSError(domain: "STSocialErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey:"Instagram OAuth was not configured", NSLocalizedRecoverySuggestionErrorKey: "Configure Instagram Service"])
    static let ytAuthError = NSError(domain: "STSocialErrorDomain", code: 2, userInfo: [NSLocalizedDescriptionKey:"YouTube OAuth was not configured", NSLocalizedRecoverySuggestionErrorKey: "Configure YouTube Service"])
}




