#
# Be sure to run `pod lib lint STWSocialKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'STWSocialKit'
s.version          = '0.1.59'
s.summary          = 'Wrapper for social media SDKs'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = <<-DESC
TODO: Add long description of the pod here.
DESC

s.homepage         = 'https://github.com/stanwood/STWSocialKit'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Tal Zion' => 'talezion@gmail.com' }
s.source           = { :git => 'https://github.com/stanwood/STWSocialKit.git', :tag => s.version.to_s }

s.ios.deployment_target = '9.3'
s.requires_arc = true

s.source_files = 'STWSocialKit/Classes/**/*'
s.resource_bundles = {
}

# s.public_header_files = 'Pod/Classes/**/*.h'
s.frameworks = 'Social'
# s.dependency 'AFNetworking', '~> 2.3'
s.dependency 'OAuthSwift', '~> 1.1.0'
s.dependency 'Locksmith', '~> 3.0.0'
s.dependency 'ObjectMapper', '~> 2.2.1'
s.dependency 'FBSDKCoreKit', '~> 4.17.0'
s.dependency 'FBSDKShareKit', '~> 4.17.0'
s.dependency 'FBSDKLoginKit', '~> 4.17.0'

end
