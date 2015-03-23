#
#  Be sure to run `pod spec lint QBSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
    s.name         = "Quickblox"
    s.version      = "1.9"
    s.summary      = "Library of classes to connect with Quickblox services"
    s.description  = <<-DESC
    A longer description of QBSDK in Markdown format.
    * Think: Why did you write this? What is the focus? What does it do?
    * CocoaPods will be using this to generate tags, and improve search results.
    * Try to keep it short, snappy and to the point.
    * Finally, don't worry about the indent, CocoaPods strips it!
    DESC
    s.homepage = "http://quickblox.com"
    s.license = "MIT"
    s.author = { "Andrey Kozlov" => "Andrey.Kozlov@betfair.com" }
    s.source = { :git => "git@github.com:QuickBlox/SDK-ios.git", :branch => "webrtc_development" }
    s.requires_arc = false
    s.platform = :ios, "6.0"
    s.ios.deployment_target = '6.0'
    
    s.subspec 'Header' do |ss|
        ss.source_files = 'Framework/Quickblox.{h}'
        ss.requires_arc = true
    end
    
    s.subspec 'QBAFNetworking' do |ss|
        ss.source_files = 'Framework/Core/External/AFNetworking-1.x/**/*.{h,m}'
        ss.requires_arc = true
        ss.dependency 'Quickblox/BaseServiceFramework'
        
        ss.frameworks =
        "MobileCoreServices",
        "SystemConfiguration",
        "AVFoundation",
        "CoreVideo",
        "Accelerate",
        "CoreMedia",
        "AudioToolbox",
        "CoreLocation",
        "CoreData",
        "CoreGraphics",
        "CFNetwork",
        "UIKit",
        "GLKit"
    end
    
    s.subspec 'QBBase64' do |ss|
        ss.source_files = 'Framework/Core/External/Base64/**/*.{h,m}'
        ss.requires_arc = true
    end
    
    s.subspec 'QBCore' do |ss|
        ss.source_files = 'Framework/QBCore/**/*.{h,m}'
        ss.requires_arc = true
        ss.dependency 'Quickblox/QBAFNetworking'
        ss.dependency 'Quickblox/UsersServiceFramework'
    end
    
    s.subspec 'BaseServiceFrameworkARC' do |ss|
        ss.requires_arc = true
        
        ss.source_files =
        'Framework/Core/External/XMPP/Vendor/CocoaAsyncSocket/QBGCDAsyncSocket.{h,m}',
        'Framework/Core/External/XMPP/Utilities/QBGCDMulticastDelegate.{h,m}',
        'Framework/Core/External/TURN/Vendors/QBGCDAsyncUdpSocket.{h,m}',
        'Framework/Core/External/XMPP/Extensions/XEP-0280/QBXMPPMessageCarbons.{h,m}',
        'Framework/Core/External/XMPP/Extensions/XEP-0280/QBXMPPMessage+XEP0280.{h,m}',
        'Framework/Core/Business/EndpointsAPIStorage/EndpointsAPIStorage.{h,m}'
    end
    
    s.subspec 'BaseServiceFramework' do |ss|
        ss.source_files = 'Framework/Core/**/*.{h,m,mm}'
        
        ss.exclude_files =
        'Framework/Core/External/AFNetworking-1.x/**/*.{h,m}',
        'Framework/Core/External/Base64/**/*.{h,m}',
        'Framework/Core/External/XMPP/Vendor/CocoaAsyncSocket/QBGCDAsyncSocket.{h,m}',
        'Framework/Core/External/XMPP/Utilities/QBGCDMulticastDelegate.{h,m}',
        'Framework/Core/External/TURN/Vendors/QBGCDAsyncUdpSocket.{h,m}',
        'Framework/Core/External/XMPP/Extensions/XEP-0280/QBXMPPMessageCarbons.{h,m}',
        'Framework/Core/Business/EndpointsAPIStorage/EndpointsAPIStorage.{h,m}'
    
        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/QBAFNetworking'
        ss.dependency 'Quickblox/QBBase64'
        ss.dependency 'Quickblox/AuthServiceFramework'
        ss.dependency 'Quickblox/ChatServiceFramework'
        ss.dependency 'Quickblox/UsersServiceFramework'
        ss.framework  = "SystemConfiguration"
        ss.vendored_library = 'Framework/Core/External/XMPP/Vendor/libidn/libidn.a'
        ss.libraries = 'xml2', 'stdc++', 'idn'
        ss.xcconfig = { 'HEADER_SEARCH_PATHS' => '"$(SDKROOT)/usr/include/libxml2"' }
    end
    
    s.subspec 'AuthServiceFramework' do |ss|
        ss.source_files = 'Framework/AuthService/**/*.{h,m,mm}'
        ss.dependency 'Quickblox/BaseServiceFramework'
    end
    
    s.subspec 'UsersServiceFramework' do |ss|
        ss.source_files = 'Framework/UsersService/**/*.{h,m,mm}'
        ss.dependency 'Quickblox/BaseServiceFramework'
    end
    
    s.subspec 'LocationServiceFramework' do |ss|
        ss.source_files = 'Framework/LocationService/**/*.{h,m,mm}'
        ss.dependency 'Quickblox/BaseServiceFramework'
    end
    
    s.subspec 'MessagesServiceFramework' do |ss|
        ss.source_files = 'Framework/MessagesService/**/*.{h,m,mm}'
        ss.dependency 'Quickblox/BaseServiceFramework'
    end
    
    s.subspec 'ContentServiceFramework' do |ss|
        ss.source_files = 'Framework/ContentService/**/*.{h,m,mm}'
        ss.dependency 'Quickblox/BaseServiceFramework'
    end
    
    s.subspec 'RatingsServiceFramework' do |ss|
        ss.source_files = 'Framework/RatingsService/**/*.{h,m,mm}'
        ss.dependency 'Quickblox/BaseServiceFramework'
        ss.dependency 'Quickblox/LocationServiceFramework'
    end
    
    s.subspec 'ChatServiceFramework' do |ss|
        
        ss.vendored_library = 'Framework/ChatService/Classes/WebRTC/libs/libCNG.a'
        
        ss.libraries =
        'CNG',
        'audio_processing',
        'crnssckbi',
        'icui18n',
        'jingle_sound',
        'remote_bitrate_estimator',
        'video_processing',
        'webrtc_common',
        'G711',
        'audio_processing_neon',
        'crssl',
        'icuuc',
        'jsoncpp',
        'rtp_rtcp',
        'video_render_module',
        'webrtc_i420',
        'G722',
        'bitrate_controller',
        'expat',
        'isac_neon',
        'media_file',
        'sqlite_regexp',
        'voice_engine',
        'webrtc_opus',
        'PCM16B',
        'common_audio',
        'field_trial_default',
        'jingle',
        'neteq',
        'srtp',
        'vpx',
        'webrtc_utility',
        '_core_neon_offsets',
        'common_audio_neon',
        'iLBC',
        'jingle_media',
        'nss_static',
        'system_wrappers',
        'vpx_asm_offsets_vp8',
        'webrtc_video_coding',
        'audio_coding_module',
        'common_video',
        'iSAC',
        'jingle_p2p',
        'opus',
        'video_capture_module',
        'vpx_asm_offsets_vpx_scale',
        'webrtc_vp8',
        'audio_conference_mixer',
        'crnspr',
        'iSACFix',
        'jingle_peerconnection',
        'paced_sender',
        'video_coding_utility',
        'webrtc',
        'yuv',
        'audio_device',
        'crnss',
        'icudata',
        'jingle_peerconnection_objc',
        'rbe_components',
        'video_engine_core',
        'webrtc_base',
        'yuv_neon'


        ss.source_files = 'Framework/ChatService/**/*.{h,m,mm}'
        
        ss.exclude_files =
        'Framework/ChatService/Classes/Net/Server/QBChat.{h,m}',
        'Framework/ChatService/Classes/Net/Server/QBChat+Deprecated.m',
        'Framework/ChatService/Classes/Net/Server/QBMulticastDelegate.{h,m}',
        'Framework/ChatService/Classes/Business/Models/QBChatDialog.{h,m}',
        'Framework/ChatService/Classes/Business/Models/QBChatRoom.{h,m}',
        'Framework/ChatService/Classes/Net/Server/QBFakeWebRTC.{h,m}'
        ss.dependency 'Quickblox/BaseServiceFramework'
        ss.dependency 'Quickblox/UsersServiceFramework'
    end
    
    s.subspec 'ChatServiceFrameworkARC' do |ss|
        ss.requires_arc = true
        ss.source_files =
        'Framework/ChatService/Classes/Net/Server/QBChat.{h,m}',
        'Framework/ChatService/Classes/Net/Server/QBChat+Deprecated.m',
        'Framework/ChatService/Classes/Net/Server/QBMulticastDelegate.{h,m}',
        'Framework/ChatService/Classes/Business/Models/QBChatDialog.{h,m}',
        'Framework/ChatService/Classes/Business/Models/QBChatRoom.{h,m}',
        'Framework/ChatService/Classes/Net/Server/QBFakeWebRTC.{h,m}'
        
        ss.dependency 'Quickblox/BaseServiceFramework'
        ss.dependency 'Quickblox/UsersServiceFramework'
    end
    
    s.subspec 'CustomObjectsFramework' do |ss|
        ss.source_files = 'Framework/CustomObjects/**/*.{h,m,mm}'
        ss.dependency 'Quickblox/BaseServiceFramework'
    end
    
    s.subspec 'QBAuth' do |ss|
        ss.source_files = 'Framework/QBAuth/**/*.{h,m}'
        ss.requires_arc = true
        ss.dependency 'Quickblox/QBCore'
    end
    
    s.subspec 'QBCustomObjects' do |ss|
        ss.source_files = 'Framework/QBCustomObjects/**/*.{h,m}'
        ss.requires_arc = true
        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/CustomObjectsFramework'
    end
    
    s.subspec 'QBLocation' do |ss|
        ss.source_files = 'Framework/QBLocation/**/*.{h,m}'
        ss.requires_arc = true
        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/LocationServiceFramework'
    end
    
    s.subspec 'QBChat' do |ss|
        ss.source_files = 'Framework/QBChat/**/*.{h,m}'
        ss.requires_arc = true
        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/ChatServiceFramework'
    end
    
    s.subspec 'QBUsers' do |ss|
        ss.source_files = 'Framework/QBUsers/**/*.{h,m}'
        ss.requires_arc = true
        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/UsersServiceFramework'
    end
    
    s.subspec 'QBMessages' do |ss|
        ss.source_files = 'Framework/QBMessages/**/*{h,m}'
        ss.requires_arc = true
        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/MessagesServiceFramework'
    end
    
    s.subspec 'QBContent' do |ss|
        ss.source_files = 'Framework/QBContent/**/*{h,m}'
        ss.requires_arc = true
        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/ContentServiceFramework'
    end
    
end