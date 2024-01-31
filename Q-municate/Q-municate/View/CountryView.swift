//
//  CountryView.swift
//  Q-municate
//
//  Created by Injoit on 12.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct CountryView: View {
    private var settings: CountryScreenSettings
    
    @ObservedObject private var viewModel: EnterViewModel
    @State private var isForwardFailedPresented: Bool = false
    @State var isPresented: Bool = false
    
    init(viewModel: EnterViewModel,
         settings: CountryScreenSettings) {
        self.viewModel = viewModel
        self.settings = settings
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                SelectCountryListView(viewModel: viewModel, settings: settings)
            }
        }
        .modifier(CountryHeader(settings: settings.header))
    }
}

public struct CountryHeader: ViewModifier {
    private var settings: CountryHeaderSettings
    
    public init(settings: CountryHeaderSettings) {
        self.settings = settings
    }
    
    public func body(content: Content) -> some View {
        content
            .navigationTitle(settings.title.text)
            .navigationBarTitleDisplayMode(settings.displayMode)
            .navigationBarBackButtonHidden(false)
            .navigationBarHidden(settings.isHidden)
            .toolbarBackground(settings.backgroundColor,for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}
