//
//  STSocialConfiguration.swift
//  StanwoodSocial
//
//  Copyright (c) 2018 stanwood GmbH
<<<<<<< Updated upstream
=======
//  Distributed under MIT licence.
>>>>>>> Stashed changes
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
import OAuthSwift
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import ObjectMapper
import Locksmith
import Social

/// ST Manager delegate
public protocol STSocialManagerDelegate {
    func didLogin(type: STSocialType, withError error: Error?)
    func didLogout(type: STSocialType?)
}

open class STSocialManager: NSObject {
    
    /// Shared singelton
    open static var shared:STSocialManager = STSocialManager()
    
    /// Service configurations
    fileprivate var configurations:STSocialConfiguration!
    
    /// Service OAuth2 handlers
    fileprivate var igOAuthSwift: OAuth2Swift?
    fileprivate var ytOAuthSwift: OAuth2Swift?
    
    /// Delegate
    public var delegate:STSocialManagerDelegate?
    
    /// Operation Queue
    fileprivate lazy var queue: OperationQueue? = OperationQueue.current
    fileprivate lazy var queueDictionary: [String: Operation] = [:]
    
    /// Internal WebView target handler
    fileprivate var target: UIViewController?
    
    /// OAth internal WebView
    lazy var internalWebViewController: STWebViewController = {
        let controller = STWebViewController()
        controller.view = UIView(frame: UIScreen.main.bounds) // needed if no nib or not loaded from storyboard
        controller.delegate = self
        controller.viewDidLoad() // allow WebViewController to use this ViewController as parent to be presented
        return controller
    }()
    
    /// Instagram token
    fileprivate var igAccessToken: String {
        get {
            return igOAuthSwift == nil ? "" : igOAuthSwift!.client.credential.oauthToken
        }
    }
    
    public var isDynamicLogin:Bool = true
    
    private override init(){
        super.init()
    }
    
    //MARK: - Handel Callback
    
    public static func handle(callbackURL url: URL) {
        if let host = url.host, host == "oauth-callback" {
            OAuthSwift.handle(url: url)
        } else if let bundle = Bundle.main.bundleIdentifier, bundle.lowercased() == url.scheme {
            // Google provider is the only one wuth your.bundle.id url schema.
            //OAuth2Swift.handle(url: url)
            OAuthSwift.handle(url: url)
        } else if url.absoluteString.contains("#access_token=") {
            // OAuth Instagram
            OAuthSwift.handle(url: url)
        }
    }
    
    //MARK: - STManager Launch Configuration
    /*
     To post-process the results from actions that require you to switch to the native Facebook app or Safari, such as Facebook Login or Facebook Dialogs
     
     :app: UIApplication
     */
    public static func configure(app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        /// Checking if Instagram OAuth
        if url.absoluteString.contains("#access_token=") {
            return true
        } else {
            /// Setting Facebook configuration
            let isHandled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[.sourceApplication] as! String!, annotation: options[.annotation])
            return isHandled
        }
    }
    
    /*
     To post-process the results from actions that require you to switch to the native Facebook app or Safari, such as Facebook Login or Facebook Dialogs
     */
    public static func configure(application: UIApplication, didFinishLaunchingWithOptions options: [AnyHashable: Any]?) {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: options)
    }
    
    // Setting configuration: execute in AppDelegate didFinishLaunchingWithOptions
    public func set(configurations:STSocialConfiguration) {
        
        self.configurations = configurations
        
        for service in self.configurations.services {
            switch service.appType {
            case .facebook:
                continue
            case .instagram:
                self.igOAuthSwift = getOAuth(forService: service)
            case .youtube:
                self.ytOAuthSwift = getOAuth(forService: service)
            }
        }
    }
    
    // MARK: - Operation Management
    
    /*
     Cancel all operations
     */
    public func cancelAllOperations() {
        for (_, operation) in queueDictionary {
            operation.cancel()
        }
        queueDictionary.removeAll()
        
        print("Canceling all operations")
    }
    
    /*
     Cancel operation from the queue
     */
    public func cancelOperation(forPostID id: String, operation: STOperation) {
        guard let operation = queueDictionary["\(operation)_\(id)"] else { return }
        operation.cancel()
        queueDictionary.removeValue(forKey: "\(operation)_\(id)")
        
        print("Operation \("\(operation)_\(id)") is canceled")
    }
    
    // MARK: - Social Share Actions
    
    /// Share post
    public func share(postLink link:String?, forType type: STSocialType, localizedStrings strings: STLocalizedShareStrings?, withPostTitle title: String? = nil, postText text: String? = nil, postImageURL urlString: String? = nil, image: UIImage? = nil) throws {
        guard link != nil else {
            throw STSocialError.shareError("No post link! Please add a post link to share")
        }
        
        switch type {
        case .facebook:
            let postURL = URL(string: link ?? "")
            let imageURL = URL(string: urlString ?? "")
            
            let content = FBSDKShareLinkContent()
            content.contentTitle = title
            content.contentDescription = text
            content.contentURL = postURL
            content.imageURL = imageURL
            
            let shareButton = FBSDKShareButton()
            shareButton.shareContent = content
            
            shareButton.sendActions(for: .touchUpInside)
            /*
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                if let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
                    socialController.setInitialText(text)
                    socialController.add(postURL)
                    socialController.add(image)
                    
                    target?.present(socialController, animated: true, completion: nil)
                }
            } else {
                
                let content = FBSDKShareLinkContent()
                content.contentTitle = title
                content.contentDescription = text
                content.contentURL = postURL
                content.imageURL = imageURL
                
                let shareButton = FBSDKShareButton()
                shareButton.shareContent = content
                
                shareButton.sendActions(for: .touchUpInside)
            }*/
        case .instagram, .youtube:
            guard target != nil else {
                throw STSocialError.shareError("No Target! Please set a target to share a post... STSocialManager.shared.set(target: target)")
            }
            
            let url = URL(string: link!)
            initiareShare(withLocalizedStrings: strings, image: image, url: url)
        }
    }
    
    fileprivate func initiareShare(withLocalizedStrings strings:STLocalizedShareStrings?, image:UIImage? = nil, url:URL? = nil) {
        
        /// Checking if we have a localised option
        let isDefault:Bool = strings == nil ? true : false
        
        let alertSheet = UIAlertController(title: isDefault ? "Share" : strings!.shareTitle, message: nil, preferredStyle: .actionSheet)
        
        let linkShare = UIAlertAction(title: isDefault ? "Share Link" : strings!.shareLink, style: .default) {
            (action) in
            self.postShare(link: url)
            
        }
        
        let imageShare = UIAlertAction(title: isDefault ? "Share Image" : strings!.shareImage, style: .default) { [unowned self] (action) in
            self.postShare(image: image)
        }
        
        let cancel = UIAlertAction(title: isDefault ? "Cancel" : strings!.cancel, style: .cancel, handler: nil)
        
        if image != nil {
            alertSheet.addAction(imageShare)
        }
        
        if url != nil {
            alertSheet.addAction(linkShare)
        }
        
        alertSheet.addAction(cancel)
        
        target?.present(alertSheet, animated: true, completion: nil)
    }
    
    //Sharing image privetaly
    fileprivate func postShare(image:UIImage? = nil, link:URL? = nil) {
        
        var objectsToShare = [Any]()
        if let _image = image {
            objectsToShare.append(_image)
        }
        
        if let _link = link {
            objectsToShare.append(_link)
        }
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        target?.present(activityViewController, animated: true, completion: {
            
        })
    }
    
    // MARK: - Social Actions
    
    // An option to post a comment with a custom pop up
    public func post(toChannel channel: String? = nil, comment: String, withObjectID id: String, type: STSocialType, url: String? = nil) throws {
        
        /// Checking if the user is loged in
        guard isLogedin(type: type) else {
            auth(forType: type)
            return
        }
        
        // Post comment
        do {
            try self.comment(channel: channel, withObjectID: id, forType: type, comment: comment, url: url)
        } catch STSocialError.commentError(let message) {
            throw STSocialError.commentError(message)
        }
    }
    
    public func postComment(channel: String? = nil, withObjectID id: String, type: STSocialType, withLocalizedStrings strings:STLocalizedCommentStrings?) {
        /// Checking if the user is loged in
        guard isLogedin(type: type) else {
            auth(forType: type)
            return
        }
        
        /// Checking if we have a localised option
        let isDefault:Bool = strings == nil ? true : false
        
        let alertSheet = UIAlertController(title: isDefault ? "Comment" : strings!.title, message: nil, preferredStyle: .alert)
        
        let send = UIAlertAction(title: isDefault ? "Send" : strings!.send, style: .default) {
            (action) in
            if let textField = alertSheet.textFields?.first {
                try? self.comment(channel: channel, withObjectID: id, forType: type, comment: textField.text ?? "", url: nil)
            }
        }
        
        let cancel = UIAlertAction(title: isDefault ? "Cancel" : strings!.cancel, style: .cancel, handler: nil)
        
        alertSheet.addTextField { (textField) in
            textField.placeholder = "Comment"
        }
        alertSheet.addAction(send)
        alertSheet.addAction(cancel)
        
        target?.present(alertSheet, animated: true, completion: nil)
    }
    
    /*
     GET social service like object
     */
    fileprivate func comment(channel: String?, withObjectID id: String, forType type: STSocialType, comment: String, url:String?) throws {
        
        switch type {
        case .facebook:
            let param = STParams.fb(comment: comment)
            let request = FBSDKGraphRequest(graphPath: "\(id)/comments", parameters: param, httpMethod: STHTTPMethod.POST.rawValue)
            _ = request?.start(completionHandler: {
                (request, any:Any?, error:Error?) in
                print(request?.urlResponse ?? "")
            })
        case .instagram:
            
            guard let _url = URL(string: "instagram://media?id=\(id)") else { return }
            
            if UIApplication.shared.canOpenURL(_url) {
                UIApplication.shared.openURL(_url)
            } else if let webUrl = URL(string: url ?? ""){
                UIApplication.shared.openURL(webUrl)
            } else {
                throw STSocialError.commentError("Please install Instagram to comment")
            }
            
            /*
            guard igOAuthSwift != nil else {
                return
            }
            
            let url = String(format: kIGCommentURL, id, igOAuthSwift!.client.credential.oauthToken)
            
            let param = STParams.ig(comment: comment)
            
            _ = igOAuthSwift?.client.post(url, parameters: param,  headers: nil, body: nil,  success: {
                (response) in
                print("Posting comment - statusCode: \(response.response.statusCode)")
            }, failure: { (error:OAuthSwiftError) in
                print(error.description)
            })*/
        case .youtube:
            
            guard ytOAuthSwift != nil else {
                return
            }
            
            let body: [String: Any] = STParams.yt(comment: comment, channel: channel ?? "", id: id)
            
            let service = getService(forType: .youtube)
            let urlString = String(format: kYTCommentURL, ytOAuthSwift!.client.credential.oauthToken)
            
            let data = try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            
            _ = ytOAuthSwift?.client.post(urlString, parameters: [:], headers: ["Content-Type":"application/json"], body: data, success: { (response) in
                print(response.response.description)
            }, failure: { (error: OAuthSwiftError) in
                print(error.description)
            })
        }
    }
    
    /*
     GET social service like object
     */
    public func getComment(objectID id: String, forType type: STSocialType, handler: @escaping STCommentHandler) {

        /// Checking if the user is loged in
        guard isLogedin(type: type) else {
            if isDynamicLogin {
                auth(forType: type)
            }
            
            handler(nil, nil)
            return
        }
        
        switch type {
        case .facebook:
            let operation = BlockOperation(block: {
                
                let param:[String : Any] = STParams.fbGetComment
                
                let request = FBSDKGraphRequest(graphPath: "\(id)/comments", parameters: param, httpMethod: STHTTPMethod.GET.rawValue)
                _ = request?.start(completionHandler: {
                    [_postID = id] (request, any:Any?, error:Error?) in
                    if error == nil {
                        
                        let likeDictionary = any as? [AnyHashable: Any]
                        let summaryDictionary = likeDictionary?[STConfigurationKey.summary.rawValue] as? [AnyHashable: Any]
                        
                        switch summaryDictionary {
                        case .some:
                            let map = Map(mappingType: .fromJSON, JSON: summaryDictionary as! [String: Any])
                            let commentObject = STComment(map: map, id: _postID)
                            
                            handler(commentObject, nil)
                            break
                        default:
                            handler(nil, nil)
                            break
                        }
                        
                    } else {
                        handler(nil, error)
                    }
                })
            })
            
            queue?.addOperation(operation)
            queueDictionary["\(STOperation.comment)_\(id)"] = operation
        case .instagram:
            
            guard igOAuthSwift != nil else {
                handler(nil, STSocialErrorDomain.igAuthError)
                return
            }
            
            let url =  String(format: kIGCommentURL, id, igOAuthSwift!.client.credential.oauthToken)
            
            let operation = BlockOperation(block: { [_id = id] in
                _ = self.igOAuthSwift?.client.get(url,
                                                  success: { (response:OAuthSwiftResponse) in
                                                    do {
                                                        if let jsonDict = try response.jsonObject() as? [String:Any] {
                                                            let map = Map(mappingType: .fromJSON, JSON: jsonDict)
                                                            var comment = STComment(map: map, id: _id)
                                                            comment.canComment = true
                                                            
                                                            handler(comment, nil)
                                                        }
                                                    } catch {
                                                        print(error)
                                                        handler(nil, error)
                                                    }
                }, failure: { (error:OAuthSwiftError) in
                    print(error.description)
                    handler(nil, error)
                })
            })
            
            queue?.addOperation(operation)
            queueDictionary["\(STOperation.comment)_\(id)"] = operation
        case .youtube:
            let dic:[String:Any] = [STCommentKey.canComment.rawValue:true]
            let map = Map(mappingType: .fromJSON, JSON: dic)
            let comment = STComment(map: map, id: id)
            handler(comment, nil)
        }
    }
    
    /*
     GET social service like object
     */
    public func getLike(objectID id: String, forType type: STSocialType, handler: @escaping STLikeHandler) {

        /// Checking if the user is loged in
        guard isLogedin(type: type) else {
            if isDynamicLogin {
                auth(forType: type)
            }
            
            handler(nil, nil)
            return
        }
        
        switch type {
        case .facebook:
            
            /// Facebook Block Operation
            let operation = BlockOperation(block: {
                let param = STParams.ytGetLike()
                let request = FBSDKGraphRequest(graphPath: "\(id)/likes", parameters: param, httpMethod: STHTTPMethod.GET.rawValue)
                _ = request?.start(completionHandler: {
                    [_postID = id] (request, any:Any?, error:Error?) in
                    
                    if error == nil {
                        let likeDictionary = any as? [AnyHashable: Any]
                        let summaryDictionary = likeDictionary?[STConfigurationKey.summary.rawValue] as? [AnyHashable: Any]
                        switch summaryDictionary {
                        case .some:
                            let map = Map(mappingType: .fromJSON, JSON: summaryDictionary as! [String: Any])
                            let likeObject = STLike(facebookMap: map, id: _postID)
                            handler(likeObject, nil)
                            break
                        default:
                            handler(nil, nil)
                        }
                    } else {
                        handler(nil, error)
                    }
                })
            })
            queue?.addOperation(operation)
            queueDictionary["\(STOperation.like)_\(id)"] = operation
        case .instagram:
            
            /// Instagram Block Operation
            
            guard igOAuthSwift != nil else {
                handler(nil, STSocialErrorDomain.igAuthError)
                return
            }
            
            let url =  String(format: kIGMediaURL, id, igOAuthSwift!.client.credential.oauthToken)
            
            let operation = BlockOperation(block: {
                _ = self.igOAuthSwift?.client.get(url, success: {
                    (response) in
                    do {
                        if let jsonDict = try response.jsonObject() as? [String:Any] {
                            let map = Map(mappingType: .fromJSON, JSON: jsonDict)
                            let likeObject = STLike(instagramMap: map)
                            handler(likeObject, nil)
                        } else {
                            handler(nil, nil)
                        }
                    } catch {
                        print(error)
                        handler(nil, error)
                    }
                }, failure: { (error:OAuthSwiftError) in
                    print(error.toNSError)
                    handler(nil, error.toNSError)
                })
            })
            queue?.addOperation(operation)
            queueDictionary["\(STOperation.like)_\(id)"] = operation
        case .youtube:
            
            /// YouTube Block Operation
            
            guard ytOAuthSwift != nil else {
                handler(nil, STSocialErrorDomain.ytAuthError)
                return
            }
            
            let paramaters = STParams.ytId(forId: id)
            let listParamaters = STParams.ytList(forId: id)
            
            let operation = BlockOperation(block: {
                /// Getting the corrent user rating
                _ = self.ytOAuthSwift?.client.get(kYTRatingURL, parameters: paramaters, headers: nil,success: {
                    [unowned self, _id = id, _param = listParamaters] (response:OAuthSwiftResponse) in
                    
                    /// Getting the videos statistics
                    _ = self.ytOAuthSwift?.client.get(kYTStatisticsURL, parameters: _param, headers: nil, success: {
                        [_response = response] (statisticResponse:OAuthSwiftResponse) in
                        
                        let (like, error) = self.getLikeObject(id: _id, fromResponse: _response, statisticResponse: statisticResponse)
                        handler(like, error)
                        
                        }, failure: { (error: OAuthSwiftError) in
                            handler(nil, error.toNSError)
                    })
                    
                    }, failure: { (error: OAuthSwiftError) in
                        print(error.errorUserInfo)
                        handler(nil, error.toNSError)
                })
            })
            queue?.addOperation(operation)
            queueDictionary["\(STOperation.like)_\(id)"] = operation
        }
    }
    
    /// Liking a social post for service
    
    public func like(postID id: String, webUrl url: String?, forSocialType type: STSocialType, handler: @escaping STSuccessBlock) throws {
        
        /// Checking if the user is loged in
        guard isLogedin(type: type) else {
            auth(forType: type)
            handler(false, nil)
            return
        }
        
        switch type {
        case .facebook:
            let request = FBSDKGraphRequest(graphPath: "\(id)/likes", parameters: [:], httpMethod: STHTTPMethod.POST.rawValue)
            _ = request?.start(completionHandler: {
                (graphRequest, any, error) in
                if error == nil {
                    if let dictionary = any as? [AnyHashable: Any], let success = dictionary["success"] as? Bool {
                        handler(success, nil)
                    }
                }
                handler(false, error)
            })
        case .instagram:
            
            guard let _url = URL(string: "instagram://media?id=\(id)") else { return }
            
            if UIApplication.shared.canOpenURL(_url) {
                UIApplication.shared.openURL(_url)
            } else if let webUrl = URL(string: url ?? ""){
                UIApplication.shared.openURL(webUrl)
            } else {
                throw STSocialError.likeError("Please install Instagram to like")
            }
          
            /*
            // Checking if Instagram Auth service was configured
            guard igOAuthSwift != nil else {
                handler(false, STSocialErrorDomain.igAuthError)
                return
            }
            
            let url = String(format: kIGLikeURL, id, igOAuthSwift == nil ? "" : igOAuthSwift!.client.credential.oauthToken)
            
            _ = igOAuthSwift?.client.post(url,
                                          success: {
                                            (response) in
                                            switch response.response.statusCode {
                                            case 200:
                                                handler(true, nil)
                                            default:
                                                handler(false, nil)
                                            }
            }, failure: { (error: OAuthSwiftError) in
                print(error.description)
                handler(false, error.toNSError)
            })*/
        case .youtube:
            
            // Checking if YouTube Auth service was configured
            guard ytOAuthSwift != nil else {
                handler(false, STSocialErrorDomain.ytAuthError)
                return
            }
            
            let paramaters = STParams.fbLike(forId: id)
            _ = ytOAuthSwift?.client.post(kYTLikeURL,
                                          parameters: paramaters,
                                          headers: nil,
                                          body: nil,
                                          success: { (response) in
                                            print(response.response.description)
                                            if response.response.statusCode == 204 {
                                                handler(true, nil)
                                            } else {
                                                handler(false, nil)
                                            }
            }, failure: { (error:OAuthSwiftError) in
                print(error.errorUserInfo, error.toNSError)
            })
        }
    }
    
    /// Unliking a sopcial post for service
    
    public func unlike(postID id: String, forSocialType type: STSocialType, handler: @escaping STSuccessBlock) {
        
        /// Checking if the user is loged in
        guard isLogedin(type: type) else {
            auth(forType: type)
            handler(false, nil)
            return
        }
        
        switch type {
        case .facebook:
            let request = FBSDKGraphRequest(graphPath: "\(id)/likes", parameters: [:], httpMethod: STHTTPMethod.DELETE.rawValue)
            _ = request?.start(completionHandler: {
                (graphRequest, any, error) in
                if error == nil {
                    if let dictionary = any as? [AnyHashable: Any], let success = dictionary["success"] as? Bool {
                        handler(success, nil)
                    }
                } else {
                    handler(false, error)
                }
                
            })
        case .instagram:
            
            // Checking if Instagram Auth service was configured
            guard igOAuthSwift != nil else {
                handler(false, STSocialErrorDomain.igAuthError)
                return
            }
            
            let url = String(format: kIGLikeURL, id, igOAuthSwift == nil ? "" : igOAuthSwift!.client.credential.oauthToken)
            
            _ = igOAuthSwift?.client.delete(url,
                                            success: {
                                                (response) in
                                                switch response.response.statusCode {
                                                case 200:
                                                    handler(true, nil)
                                                default:
                                                    handler(false, nil)
                                                }
            }, failure: { (error: OAuthSwiftError) in
                print(error.description)
                handler(false, error.toNSError)
            })
        case .youtube:
            
            // Checking if YouTube Auth service was configured
            guard ytOAuthSwift != nil else {
                handler(false, STSocialErrorDomain.ytAuthError)
                return
            }
            
            let paramaters = STParams.fbUnlike(forId: id)
            _ = ytOAuthSwift?.client.post(kYTLikeURL,
                                          parameters: paramaters,
                                          headers: nil,
                                          body: nil,
                                          success: { (response) in
                                            print(response.dataString() ?? "")
                                            if response.response.statusCode == 204 {
                                                handler(true, nil)
                                            } else {
                                                handler(false, nil)
                                            }
            }, failure: { (error: OAuthSwiftError) in
                print(error.toNSError)
                handler(false, error.toNSError)
            })
        }
    }
    
    // MARK: - Authenticating
    
    /*
     Authentication user services
     */
    public func auth(forType type: STSocialType) {
        
        guard let service = getService(forType: type) else { return }
        
        switch type {
        case .facebook:
            /// Auth Facebook
            if FBSDKAccessToken.current() == nil {
                let button = FBSDKLoginButton()
                button.readPermissions = STSocialScope.fbReadPermissions
                button.publishPermissions = STSocialScope.fbPublishPermissions
                button.delegate = self
                button.loginBehavior = .web
                button.sendActions(for: .touchUpInside)
            } else {
                delegate?.didLogin(type: type, withError: nil)
            }
        case .instagram:
            /// Auth Instagram
            if let token = service.token {
                igOAuthSwift?.client.credential.oauthToken = token
                self.setInstagramUser()
                print("Instagarm Auto Login Access_Token: \(token)")
            } else {
                /// Rauthenticating the user to Instagram
                _ = self.__onceIGAuth
            }
        case .youtube:
            /// Auth youtube
            if let _token = service.refreshToken {
                _  = ytOAuthSwift?.renewAccessToken(withRefreshToken: _token, success: {
                    [_service = service] (credential, response, parameters) in
                    //Setting the refresh token
                    _service.token = credential.oauthToken
                    
                    // Infoprming the delegate YouTube is logged in
                    self.delegate?.didLogin(type: .youtube, withError: nil)
                    
                    print("YouTube Auto Login Access_Token: \(credential.oauthToken)")
                    }, failure: { [_service = service, unowned self] (error) in
                        //If token expires, clear existing token and reauthenticating the user
                        
                        // Logging out the user
                        _service.logout()
                        
                        // Informing the delegate YouTube is logged out
                        self.delegate?.didLogout(type: .youtube)
                        
                        //Resetting YTOAuth
                        _ = self.__onceYTAuth
                        
                        
                        print(error.description)
                })
            } else {
                // Calling YT Login block
                _ = self.__onceYTAuth
            }
        }
    }
    
    fileprivate func setupYoutubeUser(refreshToken token:String){
        
        guard let service = getService(forType: .youtube) else { return }
        
        _  = ytOAuthSwift?.renewAccessToken(withRefreshToken: token, success: {
            (credential, response, parameters) in
            //Setting the refresh token
            service.token = credential.oauthToken
            
            // Infoprming the delegate YouTube is logged in
            self.delegate?.didLogin(type: .youtube, withError: nil)
            
            print("YouTube Auto Login Access_Token: \(credential.oauthToken)")
            }, failure: { (error) in
                //If token expires, clear existing token and reauthenticating the user
                
                // Logging out the user
                service.logout()
                
                // Informing the delegate YouTube is logged out
                self.delegate?.didLogout(type: .youtube)
                
                print(error.description)
        })
    }
    
    /*
     Checking if the user has been loged in
     */
    fileprivate func isLogedin(type: STSocialType) -> Bool {

        guard let service = getService(forType: type) else { return false }
        
        switch type {
        case .facebook:
            return FBSDKAccessToken.current() != nil
        case .instagram:
            /// Auth Instagram
            guard service.authRequired else { return true }
            
            if let token = service.token {
                if igOAuthSwift!.client.credential.oauthToken.characters.count == 0 {
                    igOAuthSwift?.client.credential.oauthToken = token
                    self.setInstagramUser()
                    print("Instagarm Auto Login Access_Token: \(token)")
                }
                return true
            } else {
                /// Rauthenticating the user to Instagram
                return false
            }
        case .youtube:
            /// Auth youtube
            if let _token = service.refreshToken {
                if let auth = ytOAuthSwift, !auth.client.credential.isTokenExpired() && auth.client.credential.oauthToken.characters.count > 0 {
                    return true
                } else {
                    setupYoutubeUser(refreshToken: _token)
                    return true
                }
            } else {
                return false
            }
        }
    }
    
    fileprivate func getOAuth(forService service: STSocialService) -> OAuth2Swift? {
        
        switch service.appType {
        case .facebook:
            return nil
        case .instagram:
            return OAuth2Swift(
                consumerKey:    service.appID,
                consumerSecret: service.appSecret,
                authorizeUrl:   kIGAuthorizeURL,
                responseType:   OAuthResponseType.token.rawValue
            )
        case .youtube:
            return OAuth2Swift(
                consumerKey:    service.appID,
                consumerSecret: service.appSecret,
                authorizeUrl:   kYTAuthorizeURL,
                accessTokenUrl: kYTAccessTokenURL,
                responseType:   OAuthResponseType.code.rawValue
            )
        }
    }
    
    // MARK: - Dispatch Once OAuth Blocks
    
    fileprivate lazy var __onceIGAuth: () = {
        let state = self.generateState(withLength: 20)
        self.igOAuthSwift?.authorizeURLHandler = self.getURLHandler()
        let service = self.getService(forType: .instagram)
        
        _ = self.igOAuthSwift?.authorize(
            withCallbackURL: service?.callbackURI ?? "", scope: STSocialScope.instagramScope.rawValue, state: state,
            success: { (credential, response, paramaters) in
                //Storing the token in the keychain
                self.getService(forType: .instagram)?.token = credential.oauthToken
                self.setInstagramUser()
                self.delegate?.didLogin(type: .instagram, withError: nil)
                print("Instagram Access Token: \(credential.oauthToken)")
        }, failure: { (error) in
            print(error.description)
            self.delegate?.didLogin(type: .instagram, withError: error)
        })
    }()
    
    fileprivate lazy var __onceYTAuth: () = {
        let state = self.generateState(withLength: 20)
        let parameters = STParams.ytOAuth()
        guard let service = self.getService(forType: .youtube) else { return }
        
        _ = self.ytOAuthSwift?.authorize(withCallbackURL: service.callbackURI ?? "",
                                         scope: STSocialScope.youtubeScope.rawValue,
                                         state: state,
                                         parameters: parameters,
                                         headers: nil,
                                         success: { (credential, response, parameters) in
                                            
                                            //Storing the token in the keychain
                                            self.getService(forType: .youtube)?.token = credential.oauthToken
                                            self.getService(forType: .youtube)?.refreshToken = credential.oauthRefreshToken
                                            self.delegate?.didLogin(type: .youtube, withError: nil)
                                            print("YouTube Access_Token \(parameters)")
                                            
                                            
        }, failure: { (error: OAuthSwiftError) in
            print("ERROR: \(error.description)")
            self.delegate?.didLogin(type: .youtube, withError: error)
        })
    }()
    
    // MARK: - OAuth Handlers
    
    // Initiating OAuth WebView handler
    fileprivate lazy var __onceinitWebHandler: () = {
        // init now web view handler
        let _ = self.internalWebViewController.webView
    }()
    
    fileprivate func getURLHandler() -> OAuthSwiftURLHandlerType {
        if internalWebViewController.parent == nil {
            target?.addChildViewController(internalWebViewController)
        }
        return internalWebViewController
    }
    
    public func set(target: UIViewController) {
        _ = self.__onceinitWebHandler
        self.target = target
    }
    
    // MARK: - Helpers
    
    fileprivate func getLikeObject(id: String, fromResponse response: OAuthSwiftResponse, statisticResponse statisticResponse: OAuthSwiftResponse) -> (like: STLike?, error: Error?) {
        do {
            if var jsonDoc = try response.jsonObject() as? [String: Any] {
                if let statisticDictionary = try statisticResponse.jsonObject() as? [String: Any], let items = statisticDictionary["items"] as? [Any] {
                    var statistics: [String:Any] = [:]
                    
                    for item in items {
                        if let dic = item as? [String: Any], let _stat = dic["statistics"] as? [String: Any] {
                            statistics = _stat
                        }
                    }
                    
                    jsonDoc.updateValue(statistics, forKey: "statistics")
                    
                    let map = Map(mappingType: .fromJSON, JSON: jsonDoc)
                    let likeObject = STLike(youtubeMap: map, id: id)
                    return (likeObject, nil)
                } else {
                    return (nil, nil)
                }
            } else {
                return (nil, nil)
            }
        } catch {
            print(error.localizedDescription)
            return (nil, error)
        }
    }
    
    open func getService(forType type: STSocialType) -> STSocialService? {
        
        for service in self.configurations.services {
            if service.appType == type {
                return service
            }
        }
        
        return nil
    }
    
    fileprivate func generateState(withLength len : Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let length = UInt32(letters.characters.count)
        
        var randomString = ""
        for _ in 0..<len {
            let rand = arc4random_uniform(length)
            let idx = letters.index(letters.startIndex, offsetBy: Int(rand))
            let letter = letters.characters[idx]
            randomString += String(letter)
        }
        return randomString
    }
    
    /// Setting Instagram user id
    fileprivate func setInstagramUser(){
        guard getService(forType: .instagram)?.userId == nil else { return }
        
        let url = "https://api.instagram.com/v1/users/self/?access_token=\(igAccessToken)"
        _ = igOAuthSwift?.client.get(url, success: { (response) in
            do {
                if let jsonDic = try response.jsonObject() as? [String: Any], let data = jsonDic["data"] as? [String: Any], let id = data["id"] as? String {
                    let service = self.getService(forType: .instagram)
                    service?.userId = id
                    
                    print("Setting Instagram user id: \(id)")
                }
            } catch {
                print(error)
            }
        }, failure: { (error:OAuthSwiftError) in
            print(error.description)
        })
    }
    
    // MARK: - Logout
    
    public func logout() {
        
        let cookies = HTTPCookieStorage.shared.cookies
        
        for cookie in cookies ?? [] {
            if cookie.domain.contains("instagram.com") || cookie.domain.contains("facebook.com") {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        configurations.logout()
        delegate?.didLogout(type: nil)
    }
}

// MARK: - OAuthWebViewControllerDelegate

extension STSocialManager: OAuthWebViewControllerDelegate {
    #if os(iOS) || os(tvOS)
    
    public func oauthWebViewControllerDidPresent() {
    
    }
    public func oauthWebViewControllerDidDismiss() {
    
    }
    #endif
    
    public func oauthWebViewControllerWillAppear() {
        
    }
    public func oauthWebViewControllerDidAppear() {
        
    }
    public func oauthWebViewControllerWillDisappear() {
        
    }
    public func oauthWebViewControllerDidDisappear() {
        // Ensure all listeners are removed if presented web view close
        ytOAuthSwift?.cancel()
    }
}

//MARK: - FBSDKLoginButtonDelegate
extension STSocialManager: FBSDKLoginButtonDelegate {
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        delegate?.didLogout(type: .facebook)
    }
    
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        delegate?.didLogin(type: .facebook, withError: error)
    }
}
