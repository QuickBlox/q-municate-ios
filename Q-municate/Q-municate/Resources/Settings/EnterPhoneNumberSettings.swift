//
//  EnterPhoneNumberSettings.swift
//  Q-municate
//
//  Created by Injoit on 11.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxUIKit

public class EnterPhoneNumberScreenSettings {
    public var header: EnterPhoneNumberHeaderSettings
    public var countryScreen: CountryScreenSettings
    public var verifyCodeScreen: VerifyPhoneNumberScreenSettings
    public var backgroundColor: Color
    public var countryCode: CountryCodeSettings
    public var phoneNumber: PhoneNumberSettings
    public var terms: TermsSettings
    public var blurRadius: CGFloat = 12.0
    public var progressBar: ProgressBarSettings
    public var titleOk: String
    
    init(_ theme: AppTheme) {
        self.header = EnterPhoneNumberHeaderSettings(theme)
        self.countryScreen = CountryScreenSettings(theme)
        self.verifyCodeScreen = VerifyPhoneNumberScreenSettings(theme)
        self.backgroundColor = theme.color.mainBackground
        self.countryCode = CountryCodeSettings(theme)
        self.phoneNumber = PhoneNumberSettings(theme)
        self.terms = TermsSettings(theme)
        self.progressBar = ProgressBarSettings(theme)
        self.titleOk = theme.qmunicateString.ok
    }
}

public struct CountryCodeSettings {
    public var title: String
    public var titleColor: Color
    public var titleFont: Font
    public var iconFont: Font
    public var codeColor: Color
    public var codeFont: Font
    public var arrowRight: Image
    public var arrowColor: Color
    public var tralingSpacing: CGFloat = 12
    
    init(_ theme: AppTheme) {
        self.titleFont = theme.font.headline
        self.titleColor = theme.color.mainText
        self.title = theme.qmunicateString.сountry
        self.iconFont = theme.font.callout
        self.codeFont = theme.font.callout
        self.codeColor = theme.color.mainElements
        self.arrowRight = theme.image.chevronForward
        self.arrowColor = theme.color.mainText
    }
}

public struct PhoneNumberSettings {
    public var title: String
    public var titleColor: Color
    public var titleFont: Font
    public var numberColor: Color
    public var numberFont: Font
    
    init(_ theme: AppTheme) {
        self.titleFont = theme.font.headline
        self.titleColor = theme.color.mainText
        self.title = theme.qmunicateString.number
        self.numberFont = theme.font.callout
        self.numberColor = theme.color.mainText
    }
}

public struct TermsHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var isHidden: Bool = false
    
    init(_ theme: AppTheme) {
        self.backgroundColor = theme.color.mainBackground
    }
}

public struct TermsSettings {
    public var privacyPolicy: String
    public var terms: String
    public var color: Color
    public var font: Font
    public var header: TermsHeaderSettings
    
    init(_ theme: AppTheme) {
        self.font = theme.font.caption
        self.color = theme.color.secondaryText
        self.privacyPolicy = theme.qmunicateString.privacy
        self.terms = theme.qmunicateString.terms
        self.header = TermsHeaderSettings(theme)
    }
}

public struct EnterPhoneNumberHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var title: EnterPhoneNumberTitle
    public var rightButton: GetCodeButton
    public var isHidden: Bool = false
    
    init(_ theme: AppTheme) {
        self.backgroundColor = theme.color.mainBackground
        self.title = EnterPhoneNumberTitle(theme)
        self.rightButton = GetCodeButton(theme)
    }
    
    public struct GetCodeButton {
        public var title: String
        public var color: Color
        
        init(_ theme: AppTheme) {
            self.title = theme.qmunicateString.getCode
            self.color = theme.color.mainElements
        }
    }
    
    public struct EnterPhoneNumberTitle {
        public var text: String
        public var color: Color
        public var font: Font
        
        init(_ theme: AppTheme) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
            self.text = theme.qmunicateString.enterPhoneNumber
        }
    }
}
