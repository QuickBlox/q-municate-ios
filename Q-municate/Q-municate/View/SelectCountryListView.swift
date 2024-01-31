//
//  SelectCountryListView.swift
//  Q-municate
//
//  Created by Injoit on 12.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxUIKit

struct SelectCountryListView: View {
    @Environment(\.isSearching) private var isSearching: Bool
    @Environment(\.dismiss) var dismiss
    
    private var settings: CountryScreenSettings
    
    @ObservedObject private var viewModel: EnterViewModel
    @State private var searchText = ""
    @State private var submittedSearchTerm = ""
    
    private var items: [CountryPhoneCode] {
        if settings.searchBar.isSearchable == false || submittedSearchTerm.isEmpty {
            return viewModel.countryPhoneCodes
        } else {
            return viewModel.countryPhoneCodes.filter { $0.name.lowercased()
                .contains(submittedSearchTerm.lowercased()) }
        }
    }
    
    init(viewModel: EnterViewModel,
         settings: CountryScreenSettings) {
        self.viewModel = viewModel
        self.settings = settings
    }

    var body: some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            List {
                ForEach(items) { item in
                    ZStack {
                        CountryRowView(item, isSelected: item.code == viewModel.selectedCountry.code, onTap: {item in
                            viewModel.selectCountry(item)
                            dismiss()
                        }, settings: settings.countryRow)
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                        return items.last?.id == item.id ? viewDimensions[.leading]
                        : viewDimensions[.listRowSeparatorLeading]
                    }
                }
                .listRowInsets(EdgeInsets())
            }.listStyle(.plain)
        }
        
        .if(settings.searchBar.isSearchable,
            transform: { view in
            view.searchable(text: $searchText,
                            placement: .navigationBarDrawer(displayMode: .always),
                            prompt: settings.searchBar.searchTextField.placeholderText)
            .onChange(of: searchText) { value in
                if searchText.isEmpty && !isSearching {
                    submittedSearchTerm = ""
                } else {
                    submittedSearchTerm = searchText
                }
            }
            .autocorrectionDisabled(true)
        })
    }
}

struct CountryRowView: View {
    
    private var settings: CountryRowSettings
    
    public var countryCode: CountryPhoneCode
    
    private var isSelected = false
    public var onTap: (_ countryCode: CountryPhoneCode) -> Void
    
    public init(_ countryCode: CountryPhoneCode,
                isSelected: Bool,
                onTap: @escaping (_ countryCode: CountryPhoneCode) -> Void,
                settings: CountryRowSettings) {
        self.countryCode = countryCode
        self.isSelected = isSelected
        self.onTap = onTap
        self.settings = settings
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            Text(countryCode.flag).font(settings.iconFont)
            
            Text(countryCode.dial_code + " (\(countryCode.name))")
                .foregroundColor(settings.codeColor)
                .font(settings.codeFont)
            
            Spacer()
            
            Checkbox(isSelected: isSelected) {
                onTap(countryCode)
            }
        }
        .frame(height: settings.selectHeight)
        .padding(settings.selectPadding)
        .background(settings.backgroundColor)
    }
}

struct Checkbox: View {
    public var settings = QuickBloxUIKit.settings.createDialogScreen.userRow.checkbox
    
    public var isSelected: Bool
    public var font: Font? = nil
    public var foregroundColor: Color? = nil
    public var backgroundColor: Color? = nil
    public var onTap: (() -> Void)?
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            if isSelected {
                settings.selected
                    .font(font ?? settings.font)
                    .foregroundColor(foregroundColor ?? settings.foregroundColorSelected)
                    .frame(width: settings.heightSelected, height: settings.heightSelected)
                    .background(backgroundColor ?? settings.backgroundColor)
                    .scaledToFit()
                    .clipShape(Circle())
            } else {
                Circle()
                    .strokeBorder(settings.strokeBorder, lineWidth: settings.lineWidth)
                    .frame(width: settings.heightSelected, height: settings.heightSelected)
            }
        }
        .frame(width: settings.heightButton, height: settings.heightButton)
    }
}
