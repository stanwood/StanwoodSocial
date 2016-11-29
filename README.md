
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
STSocialManager.shared.getComment(bjectID: post?.id ?? "", forType: type, handler: {
    [weak self] (commentObject, error) in
        if error == nil, commentObject != nil {
            // Setting comment object
        } else {
            // Error
        }
})

#### Liking a post

```swift

```

#### Unliking a post

```swift

```

#### Commenting on a post

```swift

```

#### Sharing a post

```swift

```

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
