
platform :ios, '10.3'
project 'Q-municate.xcodeproj'
source 'https://github.com/CocoaPods/Specs.git'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'Q-municate' do

    use_frameworks!

    pod 'UIDevice-Hardware', '~> 0.1.13'
    pod 'SAMKeychain', '~> 1.5.3'
    pod 'Reachability', '~> 3.2'
    pod 'TTTAttributedLabel', '~> 2.0.0'
    pod 'libextobjc/EXTScope', '~> 0.6'
    pod 'Flurry-iOS-SDK/FlurrySDK', '~> 10.0.1'
    pod 'NYTPhotoViewer', '~> 2.0.0'
    #Facebook
    pod 'FBSDKCoreKit', '~> 5.6.0'
    pod 'FBSDKLoginKit', '~> 5.6.0'
    #Firebase
    pod 'FirebaseUI/Phone', '~> 8.1.0'
    #ChatUI
    pod 'FFCircularProgressView', '~> 0.5'
    pod 'SDWebImage', '~> 5.2.0'
    #Chat Service
    pod 'QuickBlox', '~> 2.17.4'
    pod 'Quickblox-WebRTC', '~> 2.7.4'
    
end

target 'QMSiriExtension' do
    use_frameworks!
    
    #Chat Service
    pod 'Bolts', '~> 1.9.0'
    pod 'QuickBlox', '~> 2.17.4'

end

target 'QMShareExtension' do
    use_frameworks!

    pod 'Reachability', '~> 3.2'
    pod 'SVProgressHUD', '~> 2.2.5'
    #ChatUI
    pod 'FFCircularProgressView', '~> 0.5'
    pod 'SDWebImage', '~> 5.2.0'
    pod 'TTTAttributedLabel', '~> 2.0.0'
    #Chat Service
    pod 'Bolts', '~> 1.9.0'
    pod 'QuickBlox', '~> 2.17.4'

end

post_install do |installer|
    #Settings for extensions
    installer.pods_project.targets.each do |target|
        case target.name
            when 'Bolts','SVProgressHUD'
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
