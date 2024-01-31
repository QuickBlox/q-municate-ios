//
//  EnterScreenSettings.swift
//  Q-municate
//
//  Created by Injoit on 11.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxUIKit

public class EnterScreenSettings {
    public var updateVersionAlert: UpdateVersionAlertSettings
    public var poweredByQuickblox: String
    
    init(_ theme: AppTheme) {
        self.updateVersionAlert = UpdateVersionAlertSettings(theme)
        self.poweredByQuickblox = theme.qmunicateString.poweredByQuickblox
    }
}

public struct UpdateVersionAlertSettings {
    public var update: String
    public var newVersion: String
    public var resend: String
    public var skip: String
    
    public var updateToVersion: String
    
    init(_ theme: AppTheme) {
        self.update = theme.qmunicateString.update
        self.newVersion = theme.qmunicateString.newVersion
        self.resend = theme.qmunicateString.resend
        self.skip = theme.qmunicateString.skip
        self.updateToVersion = theme.qmunicateString.updateToVersion
    }
}
