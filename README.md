
<p align="center">
    <img src="Assets/STWSocial-Icon.png?raw=true" alt="STWSocialKit"/>
</p>


# STWSocialKit


[![Swift Version](https://img.shields.io/badge/Swift-3.0.x-orange.svg)]()

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

STWSocialKit is available through [Stanwood](https://github.com/stanwood/Cocoa_Pods_Specs.git) master specs. To install
it, simply add the following line to your Podfile, include the private source specs:

```ruby
source 'https://github.com/stanwood/Cocoa_Pods_Specs.git'
use_frameworks!

    target 'STWProject' do
    pod 'STWSocialKit'
end
```

## Configurations

1) Add services and Faceboook Configurations in `AppDelegate` `didFinishLaunchingWithOptions`

```swift
// Configure Facebook
STSocialManager.configure(application: application, didFinishLaunchingWithOptions: launchOptions)

// Configure Social Services
let facebook = STSocialService(appID: [YOU_APP_ID], appSecret: [YOU_APP_SECRET], appType: .facebook)
let instagram = STSocialService(appID: [YOU_APP_ID], appSecret: [YOU_APP_SECRET], appType: .instagram, callbackURI: [CALLBACK_URI])
let youtube = STSocialService(appID: [YOU_APP_ID], appSecret: [YOU_APP_SECRET], appType: .youtube, callbackURI: [CALLBACK_URI])

let configurations = STSocialConfiguration(services: [facebook, instagram, youtube])

_ = STSocialManager.shared.set(configurations: configurations)

```

2) Handle callback

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    
    /// Handling callback
    STSocialManager.handle(callbackURL: url)

    Confiugring with sheme
    return STSocialManager.configure(app: app, open: url, options: options)
}

func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    
    /// Handling callback
    STSocialManager.handle(callbackURL: url)
    return true
}



```

### Facebook Additional Configuration

    1. Right-click your `.plist` file and choose "Open As Source Code".

    2. Copy & Paste the XML snippet into the body of your file ( <dict>...</dict> ).

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>BUNDLE_SCHEME</string>
    </array>
    </dict>
</array>
<key>FacebookAppID</key>
<string>ID</string>
<key>FacebookDisplayName</key>
<string>DISPLAY_NAME</string>
```

    3. As we use Facebook dialogs (e.g., Login, Share, App Invites, etc.) that can perform an app switch to Facebook apps, your application's .plist also need to handle this.

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>fbapi</string>
    <string>fb-messenger-api</string>
    <string>fbauth2</string>
    <string>fbshareextension</string>
</array>
```

    4. For a quickstart help, click
[Facebook iOS Quickstart](https://developers.facebook.com/quickstarts/?platform=ios)

3) Set the target in the `YOURSocialStreamViewController` `viewDidLoad`

4) Conform to `STSocialManagerDelegate` to get login/logout notifications in `viewDidLoad`. `STSocialManager.shared.delegate = self`

5) Set YouTube callback URL schemes in `Info.plist`

```swift
func didLogout(type: STSocialType?) {
    /// Reload data
    collectionView.reloadData()
}

func didLogin(type: STSocialType, withError error: Error?) {
    /// Reload data
    collectionView.reloadData()
}
```

```swift
STSocialManager.shared.set(target: self)
```

## Authentication Flow

### Facebook

We will use `FBSDKLoginKit` for one time authentication.

### Instagram

Instagram uses `OAuth2` protocol, hence, we are using `OAuthSwift` for authenticating. We will store the initial `access_token` in the keychain, which is reused with no expiry date. 

### YouTube/Google

Google uses `OAuth2` protocol, hence, we are using `OAuthSwift` for authenticating. Once the user authenticates for the first time, we will store the `refresh_token` in the keychain, which can be reused to get a new token with no expiry date. In case the user revokes access to the app, the `refresh_token` will be revoked as well, and the user will need to authenticate again.

#### Note: Please make sure to enable Keychain Sharing

## Social Actions

#### Getting `STLike` Object

```swift
STSocialManager.shared.getLike(objectID: [POST_ID], forType: [STSocialType], handler: {
  [weak self] (likeObject, error) in
  DispatchQueue.main.async(execute: {
    if error == nil, let _likeObject = likeObject {
       // Setting like/unlike icon and like count
    } else {
       // Error
    })
})
```

#### Getting `STComment` object

```swift
STSocialManager.shared.getComment(bjectID: [POST_ID], forType: [STSocialType], handler: {
    [weak self] (commentObject, error) in
        if error == nil, commentObject != nil {
            // Setting comment object
        } else {
            // Error
        }
})
```

#### Like

Check if current post `hasLiked` & `canLike`.

```swift
guard let hasLiked = likeObject?.hasLiked,
(likeObject?.canLike)! else { return }
```

#### Liking a post

```swift
STSocialManager.shared.like(postID: [POST_ID], forSocialType: [STSocialType], handler: {
    [weak self, id = post!.id] (success: Bool) in
    DispatchQueue.main.async(execute: {
        if success {
            // Set current likeObject
            self?.likeObject?.hasLiked = true
            
            /// Set lke icon to like
        } else {
            // Failed to like the post
        }
    })
})
```

#### Unliking a post

```swift
STSocialManager.shared.unlike(postID: [POST_ID], forSocialType: [STSocialType], handler: {
    [weak self, id = post!.id] (success: Bool) in
    DispatchQueue.main.async(execute: {
        if success {
            // Set current likeObject
            self?.likeObject?.hasLiked = true

            /// Set lke icon to like
        } else {
            // Failed to like the post
        }
    })
})
```

#### Commenting on a post

```swift
// Check if user `canComment`

guard let canComment = commentObject?.canComment else { return }

if canComment {
    /// Post comment
    STSocialManager.shared.postComment(forObjectId: [POST_ID], type: [STSocialType], withLocalizedStrings: nil)
}
```

This will show a standard pop up `textField` for the user to comment.

`//TODO: Set a custom pop up option`

You can add a localised string object `STLocalizedCommentStrings`

#### Sharing a post

To share a post, use:
```swift
do {
    try STSocialManager.shared.share(postLink: likeObject?.shareLink ?? "", forType: type, localizedStrings: nil, withPostTitle: post!.author.name, postText: post!.text, postImageURL: post!.image, image: postImage.image)
} catch STSocialError.shareError(let message) {
    print(message)
} catch {
    print(error.localizedDescription)
}
```

This function will throw an `STSocialError.shareError` in case there is no target set up in the `ViewController`.

Each service offers different share features:

##### Facebook

Facebook will share the `likeObject?.shareLink`, the title, and the post image. In case the Facebook `Social` iOS SDK is available, the standard share will be used, otherwise, we will use `FBSDKShareKit`

##### YouTube

With YouTube share feature, we will use the standard iOS `UIActivityViewController` with an option to share the video thumbnail, or the video link.

For localised `actionSheet`, you can pass `STLocalizedShareStrings`.

##### Instagram 

With Instagram, we will use the standard iOS `UIActivityViewController` with an option to share the Instagram image, or the post link.

For localised `actionSheet`, you can pass `STLocalizedShareStrings`.

## Operation Management

Cancel all operations in `viewDidDisappear`. This will cancel fetching `STLike` & `STComment` objects in the queue.

```swift
STSocialManager.shared.cancelAllOperations()

```

Cancel a single operation in `UICollectionViewDelegate` `didEndDisplaying cell`

```swift
// Canceling an operation task
STSocialManager.shared.cancelOperation(forPostID: [POST_ID], operation: .like)
STSocialManager.shared.cancelOperation(forPostID: [POST_ID], operation: .comment)
```

## Logging out

Simply call `STSocialManager.shared.logout` to log out the user from all services.

## Dependencies

`STWSocialKit` comes bundled with several libraries:

```ruby
# iOS Frameworks
s.frameworks = 'Social'

#CocoaPods Frameworks
s.dependency 'OAuthSwift', '~> 1.1.0'
s.dependency 'Locksmith', '~> 3.0.0'
s.dependency 'ObjectMapper', '~> 2.2.1'
s.dependency 'FBSDKCoreKit', '~> 4.17.0'
s.dependency 'FBSDKShareKit', '~> 4.17.0'
s.dependency 'FBSDKLoginKit', '~> 4.17.0'
```

## License

STWSocialKit is a private library. See the LICENSE file for more info
