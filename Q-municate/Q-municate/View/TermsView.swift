//
//  TermsView.swift
//  Q-municate
//
//  Created by Injoit on 13.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import WebKit

struct TermsView: View {
    private var settings: TermsSettings
    
    private var urlString = EnterPhoneNumberViewConstant.privacyPolicyPath
    private var termsType: TermsType
    
    init(urlString: String,
         termsType: TermsType,
         settings: TermsSettings) {
        self.urlString = urlString
        self.termsType = termsType
        self.settings = settings
    }
    
    var body: some View {
        CustomWebView(urlString: urlString)
            .modifier(TermsHeader(termsType: termsType, settings: settings))
    }
}

struct CustomWebView: UIViewRepresentable {
    
    let webView: WKWebView
    var urlString = EnterPhoneNumberViewConstant.privacyPolicyPath
    
    init(urlString: String) {
        self.webView = WKWebView()
        self.urlString = urlString
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}

public struct TermsHeader: ViewModifier {
    private var settings: TermsSettings
    private var termsType: TermsType
    
     init(termsType: TermsType, settings: TermsSettings) {
        self.settings = settings
        self.termsType = termsType
    }
    
    public func body(content: Content) -> some View {
        content
            .navigationTitle(termsType == .pravicy ? settings.privacyPolicy : settings.terms)
            .navigationBarTitleDisplayMode(settings.header.displayMode)
            .navigationBarBackButtonHidden(false)
            .navigationBarHidden(settings.header.isHidden)
            .toolbarBackground(settings.header.backgroundColor,for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

enum TermsType {
    case pravicy, terms
}
