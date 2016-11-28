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
typealias TrainingDataResponse = (_ training: WMTraining?, _ error: Error?) -> Void

class NetworkManager {
    
    static let sharedManager = NetworkManager()
    
    fileprivate let fetcher = FetchRequestController()
    
    fileprivate init(){
    }
    
    func getMappingContent(_ type: WorkoutType, onComplition: @escaping TrainingDataResponse){
        let url = Constants.urlworkoutMapping
        
        self.fetcher.sendRequest(url, URLParams: nil, HTTPMethod: .GET, headers: nil) {
            (dataDictionary, response, error) in
            
            if error == nil && dataDictionary != nil {
                
                for (key, value) in dataDictionary! {
                    let stringKey = key as! String
                    
                    if stringKey == type.rawValue {
                        guard let dictionary = value as? [String:AnyObject] else { continue }
                        let training = WMTraining(type: stringKey, groupsDictionary: dictionary)
                        
                        onComplition(training, nil)
                        return
                    }
                }
                AppController.sharedController.logResponse("RESPONSE ERROR: \(response!)")
                onComplition(nil, nil)
            } else {
                AppController.sharedController.logResponse("RESPONSE ERROR: \(response)")
                onComplition(nil, error!)
            }
        }
    }
    
    func getStaticDataWithComplitionHandler(fromURL url: String, onComplition: @escaping StaticDataParserResponse) {
        
        self.fetcher.sendRequestWithArrayComplitionHandler(url, URLParams: nil, HTTPMethod: .GET, headers: nil) {
            (dataArray, response, error) in
            
            switch (error){
            case .none:
                
                var items:[JSONStaticItem] = []
                for item in dataArray! {
                    let objectItem = item as AnyObject
                    let map = Map(mappingType: .fromJSON, JSON: objectItem as! [String:AnyObject])
                    items.append(JSONStaticItem(map: map))
                }
                
                let staticItems = JSONStaticItems(items: items)
                onComplition(staticItems, response, nil)
                
            case .some: break

            }
        }
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
