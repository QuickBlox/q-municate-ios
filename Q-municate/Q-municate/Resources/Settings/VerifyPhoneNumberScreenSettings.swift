//
//  VerifyPhoneNumberScreenSettings.swift
//  Q-municate
//
//  Created by Injoit on 14.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxUIKit

public class VerifyPhoneNumberScreenSettings {
    public var header: VerifyPhoneNumberHeaderSettings
    public var enterCodeLabel: EnterCodeLabelSettings
    public var codeFild: CodeFildSettings
    public var backgroundColor: Color
    public var resendCode: ResendCodeButton
    public var blurRadius: CGFloat = 12.0
    public var progressBar: ProgressBarSettings
    
    init(_ theme: AppTheme) {
        self.header = VerifyPhoneNumberHeaderSettings(theme)
        self.enterCodeLabel = EnterCodeLabelSettings(theme)
        self.codeFild = CodeFildSettings(theme)
        self.backgroundColor = theme.color.mainBackground
        self.resendCode = ResendCodeButton(theme)
        self.progressBar = ProgressBarSettings(theme)
    }
}

public struct ResendCodeButton {
    public var title: String
    public var color: Color
    public var font: Font
    public var size: CGSize = CGSize(width: 128, height: 32)
    
    init(_ theme: AppTheme) {
        self.title = theme.qmunicateString.resendCode
        self.color = theme.color.mainElements
        self.font = theme.font.headline
    }
}

public struct CodeFildSettings {
    public var digitColor: Color
    public var digitFont: Font
    public var size: CGSize = CGSize(width: 26, height: 48)
    
    init(_ theme: AppTheme) {
        self.digitColor = theme.color.mainText
        self.digitFont = theme.font.largeTitle
    }
}

public struct EnterCodeLabelSettings {
    public var title: String
    public var titleColor: Color
    public var titleFont: Font
    public var numberColor: Color
    public var numberFont: Font
    
     init(_ theme: AppTheme) {
        self.titleFont = theme.font.callout
        self.titleColor = theme.color.mainText
        self.title = theme.qmunicateString.enterCode
        self.numberFont = theme.font.callout
        self.numberColor = theme.color.mainElements
    }
}

public struct VerifyPhoneNumberHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var title: VerifyPhoneNumberTitle
    public var leftButton: BackButton
    public var rightButton: VerifyButton
    public var isHidden: Bool = false
    
    init(_ theme: AppTheme) {
        self.backgroundColor = theme.color.mainBackground
        self.title = VerifyPhoneNumberTitle(theme)
        self.leftButton = BackButton(theme)
        self.rightButton = VerifyButton(theme)
    }
    
    public struct BackButton {
        public var imageSize: CGSize?
        public var frame: CGSize?
        public var image: Image
        public var color: Color
        public var scale: Double = 0.6
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 0.0,
                                                    bottom: 0.0,
                                                    trailing: 10.0)
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.back
            self.color = theme.color.mainElements
        }
    }
    
    public struct VerifyButton {
        public var title: String
        public var color: Color
        
         init(_ theme: AppTheme) {
            self.title = theme.qmunicateString.verify
            self.color = theme.color.mainElements
        }
    }
    
    public struct VerifyPhoneNumberTitle {
        public var text: String
        public var color: Color
        public var font: Font
        
         init(_ theme: AppTheme) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
             self.text = theme.qmunicateString.verifyPhoneNumber
        }
    }
}

