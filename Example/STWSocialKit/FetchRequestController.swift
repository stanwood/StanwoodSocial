//
//  FetchRequestController.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 03/05/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import Foundation

protocol HeaderProtocl {
    var value:String {get}
    var forHTTPHeaderField:String {get}
    init(value: String, forHTTPHeaderField:String)
}

/**
 Header is used to set NSURLRequest Headers
 */
struct Header: HeaderProtocl {
    var value: String
    var forHTTPHeaderField: String
    
    init(value: String, forHTTPHeaderField:String){
        self.value = value
        self.forHTTPHeaderField = forHTTPHeaderField
    }
    
}

/**
 HTTP Methods
 */

public enum HTTPMethods:String{
    case POST
    case DELETE
    case GET
    case PUT
}

typealias DataRESTResponse = (_ dataDictionary: [AnyHashable:Any]?, _ response: HTTPURLResponse?, _ error: Error?) -> Void
typealias ArrayRESTResponse = (_ dataArray: [Any]?, _ response: HTTPURLResponse?, _ error: Error?) -> Void
typealias RESTResponsePOST = (_ response: HTTPURLResponse?, _ error: Error?) -> Void
typealias DataResponse = (_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?) -> Void

class FetchRequestController {
    
    /**
     onComplition: DataResponse(data: NSData?, response: NSHTTPURLResponse?, error: NSError?) -> Void
     */
    func postRequestWithData(_ baseUrl:String, URLParams: [String:String]?, HTTPMethod method: HTTPMethods, headers: [Header]?, bodyObject: Data?, onComplition: @escaping DataResponse) {
        
        /* Configure session */
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        //MARK: - Setting URL
        guard let URL = URL(string: baseUrl) else {return}
        
        var request = URLRequest(url: URL)
        request.httpMethod = method.rawValue
        
        // Headers
        if let headers = headers {
            //MARK: - Headers
            
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.forHTTPHeaderField)
            }
        }
        
        // JSON Body
        if let body = bodyObject {
            request.httpBody = body.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)).data(using: String.Encoding.utf8)
        }
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                onComplition(data, response as? HTTPURLResponse, nil)
            } else {
                // Failure
                print(error!)
                onComplition(nil, nil, error)
            }
        })
        task.resume()
    }
    
    /**
     onComplition: DataResponse(data: NSData?, response: NSHTTPURLResponse?, error: NSError?) -> Void
     */
    func postRequest(_ baseUrl:String, URLParams: [String:String]?, HTTPMethod method: HTTPMethods, headers: [Header]?, bodyObject: [AnyHashable:Any]?, onComplition: @escaping DataResponse) {
        
        /* Configure session */
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        //MARK: - Setting URL
        guard let URL = URL(string: baseUrl) else {return}
        
        var request = URLRequest(url: URL)
        request.httpMethod = method.rawValue
        
        // Headers
        if let headers = headers {
            //MARK: - Headers
            
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.forHTTPHeaderField)
            }
        }
        
        // JSON Body
        if let body = bodyObject {
            request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        if let _bodyObject = bodyObject {
            do {
                let body = try JSONSerialization.data(withJSONObject: _bodyObject, options: [])
                request.httpBody = body
            } catch let error as NSError {
                print(error)
            }
        }
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                onComplition(data, response as? HTTPURLResponse, nil)
            } else {
                // Failure
                print(error!)
                onComplition(nil, response as? HTTPURLResponse, error)
            }
        })
        task.resume()
    }
    
    /**
     onComplition DictionaryRESTResponse = (dataDictionary: [String:AnyObject]?, response: NSHTTPURLResponse?, error: NSError?) -> Void
     */
    func postImage(_ baseUrl:String, imageData: Data?, HTTPMethod method: HTTPMethods, headers: [Header]?, bodyObject: Data? = nil, onComplition: @escaping DataRESTResponse) {
        
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        //"http://content.7nxt-api.com/v1/entries/de/mdkx/program/product_section"
        
        //MARK: - Setting URL
        
        
        guard let URL = URL(string: baseUrl) else {return}
        
        var request = URLRequest(url: URL)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            //MARK: - Headers
            
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.forHTTPHeaderField)
            }
        }
        
        if let body = bodyObject {
           request.httpBody = body
        }
        
        if let _image = imageData {
            let length = "\(_image.count)"
            request.setValue(length, forHTTPHeaderField: "Content-Length")
        }
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error == nil {
                let statusResponse = response as! HTTPURLResponse
                do {
                    let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [AnyHashable:Any]
                    onComplition(dataDictionary, statusResponse, nil)
                } catch let error as NSError {
                    print(error)
                    onComplition(nil, statusResponse, error)
                }
                
            } else {
                // Failure
                print(error!)
                onComplition(nil, nil, error)
            }
        })
        task.resume()
    }
    
    /**
     onComplition DictionaryRESTResponse = (dataDictionary: [String:AnyObject]?, response: NSHTTPURLResponse?, error: NSError?) -> Void
     */
    func sendRequest(_ baseUrl:String, URLParams: [String:String]?, HTTPMethod method: HTTPMethods, headers: [Header]?, bodyObject: [AnyHashable: Any]? = nil, onComplition: @escaping DataRESTResponse) {
        
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        //"http://content.7nxt-api.com/v1/entries/de/mdkx/program/product_section"
        
        //MARK: - Setting URL
        
        
        guard var URL = URL(string: baseUrl) else {return}
        
        var request = URLRequest(url: URL)
        request.httpMethod = method.rawValue
        
        if let params = URLParams {
            //MARK: - Paramaters
            
            URL = URL.URLByAppendingQueryParameters(params)
        }
        
        if let headers = headers {
            //MARK: - Headers
            
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.forHTTPHeaderField)
            }
        }
        
        if let _bodyObject = bodyObject {
            do {
                let body = try JSONSerialization.data(withJSONObject: _bodyObject, options: [])
                request.httpBody = body
            } catch let error {
                print(error)
            }
        }
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error == nil {
                let statusResponse = response as! HTTPURLResponse
                do {
                    let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [AnyHashable:Any]
                    onComplition(dataDictionary, statusResponse, nil)
                } catch let error as NSError {
                    print(error)
                    onComplition(nil, statusResponse, error)
                }

            } else {
                // Failure
                print(error!)
                onComplition(nil, nil, error)
            }
        })
        task.resume()
    }
    
    /**
     onComplition: ArrayRESTResponse(dataArray: [AnyObject]?, response: NSHTTPURLResponse?, error: NSError?) -> Void
     */
    func sendRequestWithArrayComplitionHandler(_ baseUrl:String, URLParams: [String:String]?, HTTPMethod method: HTTPMethods, headers: [Header]?, onComplition: @escaping ArrayRESTResponse) {
        
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        //"http://content.7nxt-api.com/v1/entries/de/mdkx/program/product_section"
        
        //MARK: - Setting URL
        _ = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        guard var URL = URL(string: baseUrl) else {return}
        
        var request = URLRequest(url: URL)
        request.httpMethod = method.rawValue
        
        if let params = URLParams {
            //MARK: - Paramaters
            
            URL = URL.URLByAppendingQueryParameters(params)
        }
        
        if let headers = headers {
            //MARK: - Headers
            
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.forHTTPHeaderField)
            }
        }
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error == nil {
                let statusResponse = response as! HTTPURLResponse
                do {
                    let dataArray = try JSONSerialization.jsonObject(with: data!, options: []) as? [Any]
                    //let staticArray = dataArray as! [StaticAnyObject]
                    onComplition(dataArray, statusResponse, nil)
                } catch let error as NSError {
                    print(error)
                    onComplition(nil, statusResponse, error)
                }
            } else {
                // Failure
                print(error!)
                onComplition(nil, nil, error)
            }
        })
        task.resume()
    }
    
}


protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = NSString(format: "%@=%@",
                                String(describing: key).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!,
                                String(describing: value).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new NSURL.
     */
    func URLByAppendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : NSString = NSString(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString as String)!
    }
    
}
