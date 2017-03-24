
platform :ios, '8.1'
xcodeproj 'Q-municate.xcodeproj'
source 'https://github.com/CocoaPods/Specs.git'

target 'Q-municate' do
    
    pod 'UIDevice-Hardware', '~> 0.1.3'
    pod 'SVProgressHUD', '~> 1.0'
    pod 'SSKeychain', '~> 1.2.2'
    pod 'SDWebImage', '~> 3.6'
    pod 'MPGNotification', '~> 1.2'
    pod 'Reachability', '~> 3.2'
    pod 'TTTAttributedLabel', '~> 2.0'
    pod 'libextobjc/EXTScope', '~> 0.4.1'
    pod 'libextobjc/EXTKeyPathCoding', '~> 0.4.1'
    pod 'Flurry-iOS-SDK/FlurrySDK'
    pod 'NYTPhotoViewer', '~> 1.1.0'
    #    pod 'QMChatViewController'
    #    pod 'QMServices'
    
    #Facebook
    pod 'FBSDKCoreKit', '~> 4.11.0'
    pod 'FBSDKShareKit', '~> 4.11.0'
    pod 'FBSDKLoginKit', '~> 4.11.0'
    
    #Twitter
    pod 'Fabric', '~> 1.6'
    pod 'Crashlytics', '~> 3.5'
    pod 'Digits', '~> 1.15'
    pod 'TwitterCore', '~> 1.15'
    
    #For development pods
    pod 'QMCVDevelopment', :path => '../QMChatViewController-ios/'
    #pod 'QMServicesDevelopment', :path => '../q-municate-services-ios/'
    
#    pod 'QMCVDevelopment', :git => 'git@github.com:QuickBlox/QMChatViewController-ios.git', :commit => '737a208c04a79c47195c22f4792ddbc0cf486d26'
    pod 'QMServicesDevelopment', :path => '../q-municate-services-ios/'
    
end

target 'QMSiriExtension' do
    
    pod 'QMServicesDevelopment', :path => '../q-municate-services-ios/'
    
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        case target.name
            when 'Bolts'
            target.build_configurations.each do |config|
                config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
            end
        end
    end
end
