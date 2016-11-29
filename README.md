# STWSocialKit

[![CI Status](http://img.shields.io/travis/Tal Zion/STWSocialKit.svg?style=flat)](https://travis-ci.org/Tal Zion/STWSocialKit)
[![Version](https://img.shields.io/cocoapods/v/STWSocialKit.svg?style=flat)](http://cocoapods.org/pods/STWSocialKit)
[![License](https://img.shields.io/cocoapods/l/STWSocialKit.svg?style=flat)](http://cocoapods.org/pods/STWSocialKit)
[![Platform](https://img.shields.io/cocoapods/p/STWSocialKit.svg?style=flat)](http://cocoapods.org/pods/STWSocialKit)

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

## Services

## Configurations

1) Add services in `AppDelegate` `didFinishLaunchingWithOptions`

```swift

let facebook = STSocialService(appID: [YOU_APP_ID], appSecret: [YOU_APP_SECRET], appType: .facebook)
let instagram = STSocialService(appID: [YOU_APP_ID], appSecret: [YOU_APP_SECRET], appType: .instagram, callbackURI: [CALLBACK_URI])
let youtube = STSocialService(appID: [YOU_APP_ID], appSecret: [YOU_APP_SECRET], appType: .youtube, callbackURI: [CALLBACK_URI])

let configurations = STSocialConfiguration(services: [facebook, instagram, youtube])

_ = STSocialManager.shared.set(configurations: configurations)

```

2) Set the target in the `SocialStreamViewController` `ViewDidLoad`

```swift
STSocialManager.shared.set(target: self)
```

## Authentication Flow

## Social Actions


## Author

Tal Zion, talezion@gmail.com

## License

STWSocialKit is a private library. See the LICENSE file for more info
