source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'

workspace 'LoginSDK'
project 'LoginSDK/LoginSDK.xcodeproj'
project 'LoginSDKSample/LoginSDKSample.xcodeproj'

target 'LoginSDK' do

	project 'LoginSDK/LoginSDK.xcodeproj'
  
  use_frameworks! :linkage => :static
  pod 'GoogleSignIn', '~> 6.1.0'
  pod 'FBSDKLoginKit', '~> 11.0'
end

target 'LoginSDKSample' do

	project 'LoginSDKSample/LoginSDKSample.xcodeproj'
	pod 'SnapKit', '~> 5.0.0'
end
