
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

## Usage

## Configurations

1) Add services in `AppDelegate` `didFinishLaunchingWithOptions`

```swift

let facebook = STSocialService(appID: [YOU_APP_ID], appSecret: [YOU_APP_SECRET], appType: .facebook)
let instagram = STSocialService(appID: [YOU_APP_ID], appSecret: [YOU_APP_SECRET], appType: .instagram, callbackURI: [CALLBACK_URI])
let youtube = STSocialService(appID: [YOU_APP_ID], appSecret: [YOU_APP_SECRET], appType: .youtube, callbackURI: [CALLBACK_URI])

let configurations = STSocialConfiguration(services: [facebook, instagram, youtube])

_ = STSocialManager.shared.set(configurations: configurations)

```

2) Set the target in the `SocialStreamViewController` `viewDidLoad`

```swift
STSocialManager.shared.set(target: self)
```

## Authentication Flow

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

#### Liking a post

Check if current post `hasLiked` & `canLike`.

```swift
guard let hasLiked = likeObject?.hasLiked,
(likeObject?.canLike)! else { return }
```

#### Likeing a post

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

This will show standard a pop up `textField` for the user to comment.

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

Each service offer different share features:

###### Facebook

Facebook will share the `likeObject?.shareLink`, the title, and the post image. In case the Facebook `Social` iOS SDK is avalible, the stadard share will be used, otherwise, we will use `FBSDKShareKit`

###### YouTube

With YouTube share feature, we will use the standard iOS `UIActivityViewController` with an option to share the video thumbnail, or the video link.

For localised `actionSheet`, you can pass `STLocalizedShareStrings`.

###### Instagram 

With Instagram, we will use the standard iOS `UIActivityViewController` with an option to share the Instagram image, or the post link.

For localised `actionSheet`, you can pass `STLocalizedShareStrings`.

## Operation Management

Cancel all operations in `viewDidDisappear`. This will cancel fetching `STLike` & `STComment` objects in the queue.

```swift
STSocialManager.shared.cancelAllOperations()

```

Cancel a sinlge operation in `UICollectionViewDelegate` `didEndDisplaying cell`

```swift
// Canceling an operation task
STSocialManager.shared.cancelOperation(forPostID: [POST_ID], operation: .like)
STSocialManager.shared.cancelOperation(forPostID: [POST_ID], operation: .comment)
```
## Author

Tal Zion, talezion@gmail.com

## License

STWSocialKit is a private library. See the LICENSE file for more info
