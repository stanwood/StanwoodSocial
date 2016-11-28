//
//  NetwrokManager.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 31/08/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import Foundation
import ObjectMapper

typealias PostsDataReponse = (_ posts: [SMPost]?, _ response: HTTPURLResponse?) -> Void
class NetworkManager {
    
    static let sharedManager = NetworkManager()
    
    fileprivate let fetcher = FetchRequestController()
    
    fileprivate init(){
    }
    
    func getPosts(withUrl url:String, onComplition: @escaping PostsDataReponse) {
        
        fetcher.sendRequest(url, URLParams: nil, HTTPMethod: .GET, headers: nil) {
            (dataDictionary, response, error) in
            if let _response = response, _response.statusCode == 200 {
                var posts = [SMPost]()
                
                for (key, postData) in dataDictionary! {
                    guard var postDictionary = postData as? [String:AnyObject] else { continue }
                    postDictionary[PostKey.key.rawValue] = key as AnyObject?
                    
                    let map = Map(mappingType: .fromJSON, JSON: postDictionary)
                    let newPost = SMPost(map: map)
                    posts.append(newPost)
                }
                
                onComplition(posts, response)
            } else {
                onComplition(nil, response)
            }
        }
    }
}
