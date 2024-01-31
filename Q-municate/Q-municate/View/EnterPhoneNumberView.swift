//
//  EnterPhoneNumberView.swift
//  Q-municate
//
//  Created by Injoit on 11.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct EnterPhoneNumberViewConstant {
    static let privacyPolicyPath = ""
    static let termsOfServicePath = ""
}

struct EnterPhoneNumberView: View {
    @State private var settings: EnterPhoneNumberScreenSettings
    private var theme: AppTheme
    @State private var isFailureAlertPresented: Bool = false
    @State private var isVerifyCodeFailureAlertPresented: Bool = false
    
    @ObservedObject private var viewModel: EnterViewModel
    
    init(theme: AppTheme, viewModel: EnterViewModel) {
        self.settings = EnterPhoneNumberScreenSettings(theme)
        self.theme = theme
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                settings.backgroundColor.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    HStack(spacing: 8) {
                        Text(settings.countryCode.title)
                            .foregroundColor(settings.countryCode.titleColor)
                            .font(settings.countryCode.titleFont)
                            .padding(.trailing, settings.countryCode.tralingSpacing)
                        
                        NavigationLink {
                            CountryView(viewModel: viewModel, settings: settings.countryScreen)
                        } label: {
                            Text(viewModel.selectedCountry.flag)
                                .font(settings.countryCode.iconFont)
                            
                            Text(viewModel.selectedCountry.dial_code + " (\(viewModel.selectedCountry.name))")
                                .foregroundColor(settings.countryCode.codeColor)
                                .font(settings.countryCode.codeFont)
                            
                            Spacer()
                            
                            settings.countryCode.arrowRight
                                .foregroundColor(settings.countryCode.arrowColor)
                                .padding(.trailing, settings.countryCode.tralingSpacing)
                        }
                        
                    }.frame(height: 22.0)
                    
                    Divider()
                    
                    HStack {
                        Text(settings.phoneNumber.title)
                            .foregroundColor(settings.phoneNumber.titleColor)
                            .font(settings.phoneNumber.titleFont)
                            .padding(.trailing, settings.countryCode.tralingSpacing)
                        
                        PhoneNumberTextField(phoneNumber: $viewModel.phoneNumber, settings: settings)
                        
                    }.frame(height: 22.0)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Spacer()
                        NavigationLink {
                            TermsView(urlString: EnterPhoneNumberViewConstant.privacyPolicyPath,
                                      termsType: .pravicy,
                                      settings: settings.terms)
                        } label: {
                            Text(settings.terms.privacyPolicy)
                                .foregroundColor(settings.terms.color)
                                .font(settings.terms.font)
                        }
                        
                        NavigationLink {
                            TermsView(urlString: EnterPhoneNumberViewConstant.termsOfServicePath,
                                      termsType: .terms,
                                      settings: settings.terms)
                        } label: {
                            Text(settings.terms.terms)
                                .foregroundColor(settings.terms.color)
                                .font(settings.terms.font)
                        }
                        
                    }.frame(height: 22.0)
                }
                .padding(.horizontal)
                .padding(.top, 56)
                
            }

            .if(viewModel.isPhoneNumberVerifiedSuccess == true, transform: { view in
                view.navigationDestination(isPresented: $viewModel.isPhoneNumberVerifiedSuccess, destination: {
                    VerifyPhoneNumberView(viewModel: viewModel,
                                          isVerifyCodeFailureAlertPresented: $isVerifyCodeFailureAlertPresented,
                                          theme: theme)
                    })
            })
            .disabled(viewModel.isProcessing == true)
            
            .if(viewModel.isProcessing == true && viewModel.isPhoneNumberVerifiedSuccess == false) { view in
                view.overlay() {
                    CustomProgressView()
                }
            }
            
            .if(viewModel.isPhoneNumberVerifiedSuccess == false, transform: { view in
                view.onChange(of: viewModel.error) { newValue in
                    if newValue == AuthError.networkError.localizedDescription {
                        return
                    }
                    if newValue.isEmpty == false && viewModel.isPhoneNumberVerifiedSuccess == false {
                        isFailureAlertPresented = true
                    }
                }
            })
            
            .onChange(of: viewModel.verifyCodeError) { newValue in
                if newValue.isEmpty == false && viewModel.isPhoneNumberVerifiedSuccess == true {
                    isVerifyCodeFailureAlertPresented = true
                }
            }
            
            .if(isFailureAlertPresented == true && viewModel.isPhoneNumberVerifiedSuccess == false, transform: { view in
                view.enterPhoneFailureAlert(isPresented: $isFailureAlertPresented,
                                            message: viewModel.error,
                                            onDismiss: {
                    viewModel.error = ""
                }, settings: settings)
            })
            
            .modifier(EnterPhoneNumberHeader(onTapGetCode: {
                viewModel.verifyPhoneNumber()
            }, disabled: viewModel.phoneNumber.isEmpty == true
                                             || viewModel.isCodeSendingBlocked == true
                                             || viewModel.isProcessing == true,
                                             settings: settings.header))
            
        }.accentColor(settings.header.rightButton.color)
    }
}

public struct PhoneNumberTextField: View {
    private var settings: EnterPhoneNumberScreenSettings

    @Binding var phoneNumber: String
    @FocusState private var focused: Bool?
    
    init(phoneNumber: Binding<String>,
         settings: EnterPhoneNumberScreenSettings) {
        _phoneNumber = phoneNumber
        self.settings = settings
    }
    
    public var body: some View {
        TextField("", text: $phoneNumber)
            .focused($focused, equals: true)
            .keyboardType(.numberPad)
            .foregroundColor(settings.phoneNumber.numberColor)
            .font(settings.phoneNumber.numberFont)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.focused = true
                }
            }
    }
}


struct EnterPhoneNumberHeaderToolbarContent: ToolbarContent {
    
    private var settings: EnterPhoneNumberHeaderSettings
    
    let onTapGetCode: () -> Void
    var disabled: Bool = false
    
    init(onTapGetCode: @escaping () -> Void,
         disabled: Bool,
         settings: EnterPhoneNumberHeaderSettings) {
        self.onTapGetCode = onTapGetCode
        self.disabled = disabled
        self.settings = settings
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(settings.title.text)
                .font(settings.title.font)
                .foregroundColor(settings.title.color)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onTapGetCode()
            } label: {
                Text(settings.rightButton.title)
                    .foregroundColor(settings.rightButton.color.opacity(disabled == false ? 1.0 : 0.4))
            }.disabled(disabled)
        }
    }
}

public struct EnterPhoneNumberHeader: ViewModifier {
    
    private var settings: EnterPhoneNumberHeaderSettings
    
    private let onTapGetCode: () -> Void
    private var disabled: Bool = false
    
    init(onTapGetCode: @escaping () -> Void,
         disabled: Bool,
         settings: EnterPhoneNumberHeaderSettings) {
        self.onTapGetCode = onTapGetCode
        self.disabled = disabled
        self.settings = settings
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            EnterPhoneNumberHeaderToolbarContent(onTapGetCode: onTapGetCode,
                                                 disabled: disabled,
                                                 settings: settings)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(settings.isHidden)
        .toolbarBackground(settings.backgroundColor,for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarRole(.editor)
    }
}

struct EnterPhoneFailureAlert: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let onDismiss: () -> Void
    
    let settings: EnterPhoneNumberScreenSettings
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            content.blur(radius: isPresented ? 12.0 : 0.0)
                .disabled(isPresented)
                .alert("", isPresented: $isPresented) {
                    Button(settings.titleOk, action: {
                        isPresented = false
                        onDismiss()
                    })
                } message: {
                    Text(message)
                }
        }
    }
}

extension View {
    func enterPhoneFailureAlert(
        isPresented: Binding<Bool>,
        message: String, onDismiss: @escaping () -> Void,
        settings: EnterPhoneNumberScreenSettings
    ) -> some View {
        self.modifier(EnterPhoneFailureAlert(isPresented: isPresented,
                                             message: message,
                                             onDismiss: onDismiss,
                                             settings: settings))
    }
}

public var isIphone: Bool {
    UIDevice.current.userInterfaceIdiom == .phone
}

public var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}
