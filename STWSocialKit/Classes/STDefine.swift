//
//  STDefine.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 24/11/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import Foundation

// MARK: - typealias blocks

public typealias STSuccessBlock = (_ success: Bool, _ error: Error?) -> Void
public typealias STLikeHandler = (_ likeObject: STLike?, _ error: Error?) -> Void
public typealias STCommentHandler = (_ likeObject: STComment?, _ error: Error?) -> Void

// MARK: - Social Constants

// Instagram
internal let kIGAuthorizeURL = "https://api.instagram.com/oauth/authorize"

// YouTube
internal let kYTAuthorizeURL = "https://accounts.google.com/o/oauth2/auth"
internal let kYTAccessTokenURL = "https://accounts.google.com/o/oauth2/token"
internal let kYTLikeURL = "https://www.googleapis.com/youtube/v3/videos/rate"
internal let kYTRatingURL = "https://www.googleapis.com/youtube/v3/videos/getRating"
internal let kYTStatisticsURL = "https://www.googleapis.com/youtube/v3/videos"

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
}
