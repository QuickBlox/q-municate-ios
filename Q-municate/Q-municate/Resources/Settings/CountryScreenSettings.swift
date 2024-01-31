//
//  CountryScreenSettings.swift
//  Q-municate
//
//  Created by Injoit on 11.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxUIKit

public class CountryScreenSettings {
    public var header: CountryHeaderSettings
    public var searchBar: CountrySearchBarSettings
    public var backgroundColor: Color
    public var countryRow: CountryRowSettings
    public var blurRadius: CGFloat = 12.0
    public var progressBar: ProgressBarSettings
    
    init(_ theme: AppTheme) {
        self.header = CountryHeaderSettings(theme)
        self.searchBar = CountrySearchBarSettings(theme)
        self.backgroundColor = theme.color.mainBackground
        self.countryRow = CountryRowSettings(theme)
        self.progressBar = ProgressBarSettings(theme)
    }
}

public struct CountrySearchBarSettings {
    public var isSearchable: Bool = true
    public var searchTextField: DialogsSearchTextField
    
    init(_ theme: AppTheme) {
        self.searchTextField = DialogsSearchTextField(theme)
    }
    
    public struct DialogsSearchTextField {
        public var placeholderText: String
        public var placeholderColor: Color
        public var backgroundColor: Color
        
        init(_ theme: AppTheme) {
            self.placeholderColor = theme.color.secondaryText
            self.backgroundColor = theme.color.inputBackground
            self.placeholderText = theme.string.search
        }
    }
}

public struct CountryRowSettings {
    public var backgroundColor: Color
    public var iconFont: Font
    public var codeColor: Color
    public var codeFont: Font
    public var selectHeight: CGFloat = 56
    public var selectPadding: EdgeInsets = EdgeInsets(top: 0,
                                                      leading: 16,
                                                      bottom: 0,
                                                      trailing: 16)
    
    init(_ theme: AppTheme) {
        self.backgroundColor = theme.color.mainBackground
        self.iconFont = theme.font.callout
        self.codeFont = theme.font.callout
        self.codeColor = theme.color.mainText
    }
}

public struct CountryHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var title: CountryTitle
    public var leftButton: BackButton
    public var isHidden: Bool = false
    
    init(_ theme: AppTheme) {
        self.backgroundColor = theme.color.mainBackground
        self.title = CountryTitle(theme)
        self.leftButton = BackButton(theme)
    }
    
    public struct BackButton {
        public var title: String?
        public var image: Image
        public var color: Color
        public var scale: Double = 0.5
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 16.0,
                                                    bottom: 0.0,
                                                    trailing: 0.0)
        
        init(_ theme: AppTheme) {
            self.image = theme.image.back
            self.color = theme.color.mainElements
        }
    }
    
    public struct CountryTitle {
        public var text: String
        public var color: Color
        public var font: Font
        
        init(_ theme: AppTheme) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
            self.text = theme.qmunicateString.сountry
        }
    }
}

