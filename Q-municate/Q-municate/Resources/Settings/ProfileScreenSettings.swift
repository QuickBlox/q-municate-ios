//
//  ProfileScreenSettings.swift
//  Q-municate
//
//  Created by Injoit on 14.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

public class ProfileScreenSettings {
    public var header: SettingsHeaderSettings
    public var backgroundColor: Color
    public var avatar: Image
    public var blurRadius: CGFloat = 12.0
    public var dividerColor: Color
    public var height: CGFloat = 56.0
    public var spacing: CGFloat = 16.0
    public var hint: HintSettings
    public var textfieldPrompt: String
    public var mediaAlert: MediaAlert
    public var avatarSize: CGSize = CGSize(width: 80.0, height: 80.0)
    public var isHiddenFiles: Bool = true
    public var maximumMB: Double = 10
    public var logoutButton: LogoutButton
    public var logoutAlert: LogoutAlertSettings
    
    init(_ theme: AppTheme) {
        self.header = SettingsHeaderSettings(theme)
        self.mediaAlert = MediaAlert(theme)
        self.backgroundColor = theme.color.mainBackground
        self.avatar = theme.image.avatarUser
        self.dividerColor = theme.color.divider
        self.hint = HintSettings(theme)
        self.textfieldPrompt = theme.qmunicateString.enterYourName
        self.logoutButton = LogoutButton(theme)
        self.logoutAlert = LogoutAlertSettings(theme)
    }
}

public struct LogoutAlertSettings {
    public var title: String
    public var cancel: String
    public var ok: String
    
    init(_ theme: AppTheme) {
        self.title = theme.qmunicateString.logOutPrompt
        self.cancel = theme.qmunicateString.cancel
        self.ok = theme.qmunicateString.ok
    }
}

public struct LogoutButton {
    public var title: String
    public var color: Color
    public var font: Font
    public var size: CGSize = CGSize(width: 128, height: 32)
    
    init(_ theme: AppTheme) {
        self.color = theme.color.mainElements
        self.title = theme.qmunicateString.logOut
        self.font = theme.font.headline
    }
}

public struct HintSettings {
    public var text: String
    public var color: Color
    public var font: Font
    
    init(_ theme: AppTheme) {
        self.font = theme.font.caption
        self.color = theme.color.secondaryElements.opacity(0.4)
        self.text = theme.qmunicateString.hintName
    }
}

public struct MediaAlert {
    public var title: String
    public var removePhoto: String
    public var camera: String
    public var gallery: String
    public var cancel: String
    public var file: String
    public var galleryMediaTypes: [String] = [UTType.image.identifier]
    public var fileMediaTypes: [UTType] = [.jpeg, .png, .heic, .heif, .image]
    public var blurRadius:CGFloat = 12.0
    
    init(_ theme: AppTheme) {
        self.title = theme.string.photo
        self.removePhoto = theme.string.removePhoto
        self.camera = theme.string.camera
        self.gallery = theme.string.gallery
        self.file = theme.string.file
        self.cancel = theme.string.cancel
    }
}

public struct SettingsHeaderSettings {
    public var title: ProfileTitle
    public var rightButton: FinishButton
    
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var opacity: CGFloat = 0.4
    public var isHidden: Bool = false
    
    init(_ theme: AppTheme) {
        self.backgroundColor = theme.color.mainBackground
        self.title = ProfileTitle(theme)
        self.rightButton = FinishButton(theme)
    }
    
    public struct FinishButton {
        public var finish: String
        public var save: String
        public var color: Color
        
        init(_ theme: AppTheme) {
            self.color = theme.color.mainElements
            self.finish = theme.qmunicateString.finish
            self.save = theme.qmunicateString.save
        }
    }
    
    public struct ProfileTitle {
        public var settings: String
        public var profile: String
        public var color: Color
        public var font: Font
        
        init(_ theme: AppTheme) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
            self.settings = theme.qmunicateString.settings
            self.profile = theme.qmunicateString.createProfile
        }
    }
}
