#
# Be sure to run `pod lib lint StanwoodSocial.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'StanwoodSocial'
s.version          = '0.1.9'
s.summary          = 'Wrapper for social media SDKs'
s.description      = <<-DESC
'Wrapper for social media sdk'
DESC

s.homepage         = 'https://github.com/stanwood/StanwoodSocial'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Tal Zion' => 'talezion@gmail.com' }
s.source           = { :git => 'https://github.com/stanwood/StanwoodSocial.git', :tag => s.version.to_s }

s.ios.deployment_target = '10'
s.requires_arc = true

s.source_files = 'STWSocialKit/Classes/**/*'
s.resource_bundles = {
}

s.frameworks = 'Social'
s.dependency 'OAuthSwift', '~> 1.1.2'
s.dependency 'Locksmith', '~> 4.0.0'
s.dependency 'ObjectMapper', '~> 2.2.1'
s.dependency 'FBSDKCoreKit', '~> 4.17.0'
s.dependency 'FBSDKShareKit', '~> 4.17.0'
s.dependency 'FBSDKLoginKit', '~> 4.17.0'

end
