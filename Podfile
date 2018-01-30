
platform :ios, '9.0'
xcodeproj 'Q-municate.xcodeproj'
source 'https://github.com/CocoaPods/Specs.git'


def services
    
#    pod 'QMServicesDevelopment', :path => '../q-municate-services-ios/'
#    pod 'QMServicesDevelopment', :git => 'git@github.com:QuickBlox/q-municate-services-ios.git', :tag => '0.5.3'
    pod 'QMServicesDevelopment',:git => 'git@github.com:QuickBlox/q-municate-services-ios.git', :branch => 'development'
end

def chat_view_controller
    
#    pod 'QMCVDevelopment', :path => '../QMChatViewController-ios/'
    pod 'QMCVDevelopment', :git => 'git@github.com:QuickBlox/QMChatViewController-ios.git', :branch => 'development'
end


target 'Q-municate' do
    
    chat_view_controller
    services
    
    pod 'UIDevice-Hardware', '~> 0.1.11'
    pod 'SAMKeychain'
    pod 'Reachability', '~> 3.2'
    pod 'TTTAttributedLabel', '~> 2.0'
    pod 'libextobjc/EXTScope', '~> 0.4.1'
    pod 'Flurry-iOS-SDK/FlurrySDK', '<= 8.3.1'
    pod 'NYTPhotoViewer', :git => 'https://github.com/NYTimes/NYTPhotoViewer.git', :tag => 'v2.0.0'
    
    #Facebook
    pod 'FBSDKCoreKit'
    pod 'FBSDKShareKit'
    pod 'FBSDKLoginKit'
    #Twitter
    pod 'Fabric'
    pod 'Crashlytics'
    #Firebase
    pod 'FirebaseUI/Phone', '~> 4.0'
    
end

target 'QMSiriExtension' do
    
    services
    
end

target 'QMShareExtension' do
    
    services
    chat_view_controller
    
    pod 'Reachability', '~> 3.2'
    pod 'SVProgressHUD'
    
end

post_install do |installer|
    #Settings for extensions
    installer.pods_project.targets.each do |target|
        case target.name
            when 'Bolts','QMCVDevelopment','SVProgressHUD'
            target.build_configurations.each do |config|
                config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
            end
        end
        if target.name == "SVProgressHUD"
            target.build_configurations.each do |config|
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'SV_APP_EXTENSIONS'
            end
        end
        
    end
    
    #This script fixes an issue with application icon on iOS 11
    #MORE INFO: https://github.com/CocoaPods/CocoaPods/issues/7003
    installer.aggregate_targets.each do |target|
        case target.name
            when 'Pods-Q-municate'
            copy_pods_resources_path = "Pods/Target Support Files/#{target.name}/#{target.name}-resources.sh"
            string_to_replace = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"'
            assets_compile_with_app_icon_arguments = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"'
            text = File.read(copy_pods_resources_path)
            new_contents = text.gsub(string_to_replace, assets_compile_with_app_icon_arguments)
            File.open(copy_pods_resources_path, "w") {|file| file.puts new_contents }
        end
    end
end
