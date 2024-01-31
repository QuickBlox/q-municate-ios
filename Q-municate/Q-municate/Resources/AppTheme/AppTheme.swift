//
//  AppTheme.swift
//  UIKitSample
//
//  Created by Injoit on 15.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxUIKit
import QBAIRephrase

var appThemes: [AppTheme] = [AppTheme(color: QuickBloxUIKit.ThemeColor(),
                                      font: QuickBloxUIKit.ThemeFont(),
                                      image: QuickBloxUIKit.ThemeImage(),
                                      string: QuickBloxUIKit.ThemeString(),
                                      qmunicateString: QmunicateString())
]

class AppTheme: ThemeProtocol, ObservableObject {
    @Published var color: ThemeColorProtocol
    @Published var font: ThemeFontProtocol
    @Published var image: ThemeImageProtocol
    @Published var string: ThemeStringProtocol
    @Published var qmunicateString: QmunicateStringProtocol
    
    init(color: ThemeColorProtocol,
         font: ThemeFontProtocol,
         image: ThemeImageProtocol,
         string: ThemeStringProtocol,
         qmunicateString: QmunicateStringProtocol) {
        self.color = color
        self.font = font
        self.image = image
        self.string = string
        self.qmunicateString = qmunicateString
    }
}

public protocol QmunicateStringProtocol {
    var сountry: String { get set }
    var number: String { get set }
    var privacy: String { get set }
    var terms: String { get set }
    var enterPhoneNumber: String { get set }
    var verifyPhoneNumber: String { get set }
    var getCode: String { get set }
    var verify: String { get set }
    var resendCode: String { get set }
    var enterCode: String { get set }
    var createProfile: String { get set }
    var finish: String { get set }
    var save: String { get set }
    var editedName: String { get set }
    var settings: String { get set }
    var enterYourName: String { get set }
    var hintName: String { get set }
    var dialogs: String { get set }
    var cancel: String { get set }
    var logOut: String { get set }
    var logOutPrompt: String { get set }
    var ok: String { get set }
    
    var update: String { get set }
    var newVersion: String { get set }
    var resend: String { get set }
    var skip: String { get set }
    var poweredByQuickblox: String { get set }
    var updateToVersion: String { get set }
    

}

public class QmunicateString: QmunicateStringProtocol {

    public var сountry: String = String(localized: "qmunicate.auth.сountry")
    public var number: String = String(localized: "qmunicate.auth.number")
    public var privacy: String = String(localized: "qmunicate.auth.privacy")
    public var terms: String = String(localized: "qmunicate.auth.terms")
    public var enterPhoneNumber: String = String(localized: "qmunicate.auth.enterPhoneNumber")
    public var verifyPhoneNumber: String = String(localized: "qmunicate.auth.verifyPhoneNumber")
    public var getCode: String = String(localized: "qmunicate.auth.getCode")
    public var verify: String = String(localized: "qmunicate.auth.verify")
    public var resendCode: String = String(localized: "qmunicate.auth.resendCode")
    public var enterCode: String = String(localized: "qmunicate.auth.enterCode")
    public var createProfile: String = String(localized: "qmunicate.settings.createProfile")
    public var finish: String = String(localized: "qmunicate.settings.finish")
    public var save: String = String(localized: "qmunicate.settings.save")
    public var editedName: String = String(localized: "qmunicate.settings.editedName")
    public var settings: String = String(localized: "qmunicate.settings.settings")
    public var enterYourName: String = String(localized: "qmunicate.settings.enterYourName")
    public var hintName: String = String(localized: "qmunicate.settings.hint")
    public var dialogs: String = String(localized: "qmunicate.settings.dialogs")
    public var cancel: String = String(localized: "qmunicate.settings.cancel")
    public var logOut: String = String(localized: "qmunicate.settings.logOut")
    public var logOutPrompt: String = String(localized: "qmunicate.settings.logOutPrompt")
    public var ok: String = String(localized: "qmunicate.settings.ok")
    
    public var update: String = String(localized: "qmunicate.update.update")
    public var newVersion: String = String(localized: "qmunicate.update.newVersion")
    public var resend: String = String(localized: "qmunicate.update.resend")
    public var skip: String = String(localized: "qmunicate.update.skip")
    public var updateToVersion: String = String(localized: "qmunicate.update.updateToVersion")
    public var poweredByQuickblox: String = String(localized: "qmunicate.settings.poweredByQuickblox")
    
    public init() {}
}

enum ApplicationZone {
    case develop, prod, qa
}

let currentApplicationZone: ApplicationZone = .prod
