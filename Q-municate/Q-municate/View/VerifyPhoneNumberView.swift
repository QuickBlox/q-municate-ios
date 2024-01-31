//
//  VerifyPhoneNumberView.swift
//  Q-municate
//
//  Created by Injoit on 13.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import Combine

struct VerifyPhoneNumberView: View {
    @Environment(\.dismiss) var dismiss
    private var settings: VerifyPhoneNumberScreenSettings
    private var theme: AppTheme
    
    @State private var isVerifyCodeTapped: Bool = false
    @Binding private var isVerifyCodeFailureAlertPresented: Bool
    @FocusState private var isTextFieldFocused: Bool
    
    @ObservedObject private var viewModel: EnterViewModel
    
    init(viewModel: EnterViewModel,
         isVerifyCodeFailureAlertPresented: Binding<Bool>,
         theme: AppTheme) {
        self.viewModel = viewModel
        
        self.settings = VerifyPhoneNumberScreenSettings(theme)
        self.theme = theme
        _isVerifyCodeFailureAlertPresented = isVerifyCodeFailureAlertPresented
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            settings.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                Text(settings.enterCodeLabel.title)
                    .foregroundColor(settings.enterCodeLabel.titleColor)
                    .font(settings.enterCodeLabel.titleFont)
                
                Text(viewModel.selectedCountry.dial_code + " \(viewModel.phoneNumber)")
                    .foregroundColor(settings.enterCodeLabel.numberColor)
                    .font(settings.enterCodeLabel.numberFont)
                
                SMSCodeEnterFieldView(numberOfFields: 6, smsCode: $viewModel.smsCode, settings: settings)
                    .onChange(of: viewModel.smsCode) { newSMSCode in
                        if newSMSCode.count > 6 {
                            viewModel.smsCode = String(viewModel.smsCode.prefix(6))
                        }
                    }
                    .padding(.vertical, 36)
                    .focused($isTextFieldFocused, equals: true)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isTextFieldFocused = true
                        }
                    }
                
                if viewModel.isCodeSendingBlocked == false {
                    Button {
                        if viewModel.isCodeSendingBlocked == false {
                            viewModel.verifyPhoneNumber()
                        }
                    } label: {
                        Text(settings.resendCode.title)
                            .foregroundColor(viewModel.isCodeSendingBlocked == false ? settings.resendCode.color : settings.resendCode.color.opacity(0.4))
                            .font(settings.resendCode.font)
                    }
                    .disabled(viewModel.isCodeSendingBlocked == true)
                } else {
                    Text("Re-send in 00:\(timeFormatted(viewModel.totalResendTime))")
                        .foregroundColor(settings.enterCodeLabel.numberColor)
                        .font(settings.enterCodeLabel.numberFont)
                }
                
                Spacer()
                
            }
            .padding(.horizontal)
            .padding(.top, 56)
        }
        
        .if(viewModel.isVerifyCodeProcessing == true) { view in
            view.overlay() {
                CustomProgressView()
            }
        }
        
        .if(isVerifyCodeFailureAlertPresented == true, transform: { view in
            view.enterPhoneFailureAlert(isPresented: $isVerifyCodeFailureAlertPresented,
                                        message: viewModel.verifyCodeError,
                                        onDismiss: {
                viewModel.verifyCodeError = ""
            }, settings: EnterPhoneNumberScreenSettings(theme))
        })
        
        .disabled(viewModel.isVerifyCodeProcessing == true)
        .modifier(EnterCodeHeader(onDismiss: {
            viewModel.isPhoneNumberVerifiedSuccess = false
            viewModel.invalidateResendCodeTimer()
            dismiss()
        }, onTapVerifyCode: {
            viewModel.verifyCode()
        }, disabled: viewModel.smsCode.count != 6 || viewModel.isVerifyCodeProcessing == true,
                                  settings: settings.header))
    }
}


struct EnterCodeHeaderToolbarContent: ToolbarContent {
    private var settings: VerifyPhoneNumberHeaderSettings
    
    private let onDismiss: () -> Void
    private let onTapVerifyCode: () -> Void
    private var disabled: Bool = false
    
    init(onDismiss: @escaping () -> Void,
         onTapVerifyCode: @escaping () -> Void,
         disabled: Bool,
         settings: VerifyPhoneNumberHeaderSettings) {
        self.onDismiss = onDismiss
        self.onTapVerifyCode = onTapVerifyCode
        self.disabled = disabled
        self.settings = settings
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                onDismiss()
            } label: {
                settings.leftButton.image
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(settings.leftButton.scale)
                    .tint(settings.leftButton.color)
                    .padding(settings.leftButton.padding)
                
            }.frame(width: 32, height: 44)
        }
        
        ToolbarItem(placement: .principal) {
            Text(settings.title.text)
                .font(settings.title.font)
                .foregroundColor(settings.title.color)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onTapVerifyCode()
            } label: {
                Text(settings.rightButton.title)
                    .foregroundColor(settings.rightButton.color.opacity(disabled == false ? 1.0 : 0.4))
            }.disabled(disabled)
        }
    }
}

public struct EnterCodeHeader: ViewModifier {
    private var settings: VerifyPhoneNumberHeaderSettings
    
    private let onDismiss: () -> Void
    private let onTapVerifyCode: () -> Void
    private var disabled: Bool = false
    
    init(onDismiss: @escaping () -> Void,
         onTapVerifyCode: @escaping () -> Void,
         disabled: Bool,
         settings: VerifyPhoneNumberHeaderSettings) {
        self.onDismiss = onDismiss
        self.onTapVerifyCode = onTapVerifyCode
        self.disabled = disabled
        self.settings = settings
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            EnterCodeHeaderToolbarContent(onDismiss: onDismiss, onTapVerifyCode: onTapVerifyCode, disabled: disabled, settings: settings)
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

struct SMSCodeEnterFieldView: View {
    private var settings: VerifyPhoneNumberScreenSettings
    
    @Binding private var smsCode: String
    @State private var digits: [String]
    @FocusState private var digitFocusState: FocusDigit?
    
    var numberOfFields: Int
    
    enum FocusDigit: Hashable {
        case digit(Int)
    }
    
    init(numberOfFields: Int, smsCode: Binding<String>,
         settings: VerifyPhoneNumberScreenSettings) {
        self.numberOfFields = numberOfFields
        self._smsCode = smsCode
        self.settings = settings
        self._digits = State(initialValue: Array(repeating: "", count: numberOfFields))
    }
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<numberOfFields, id: \.self) { index in
                TextField("", text: $digits[index])
                    .tint(.clear)
                    .modifier(DigitalCodeModifier(digit: $digits[index]))
                    .foregroundColor(settings.codeFild.digitColor)
                    .onChange(of: smsCode, perform: { newValue in
                        if newValue.isEmpty {
                            digits = Array(repeating: "", count: numberOfFields)
                            setupDigits()
                        }
                    })
                    .onChange(of: digits[index]) { newVal in
                        if newVal.count == 1 {
                            if index < numberOfFields - 1 {
                                digitFocusState = FocusDigit.digit(index + 1)
                            }
                        }
                        else if newVal.count == numberOfFields {
                            smsCode = newVal
                            setupDigits()
                            digitFocusState = FocusDigit.digit(numberOfFields - 1)
                        }
                        else if newVal.isEmpty {
                            if index > 0 {
                                digitFocusState = FocusDigit.digit(index - 1)
                            }
                        }
                        setupSMSCode()
                    }
                    .focused($digitFocusState, equals: FocusDigit.digit(index))
                    .onTapGesture {
                        digitFocusState = FocusDigit.digit(index)
                    }
            }
        }
        .onAppear {
            setupDigits()
        }
    }
    
    private func setupSMSCode() {
        smsCode = digits.joined()
    }
    
    private func setupDigits() {
        let digitsArray = Array(smsCode.prefix(numberOfFields))
        for (index, char) in digitsArray.enumerated() {
            digits[index] = String(char)
        }
        digitFocusState = FocusDigit.digit(0)
    }
}

struct DigitalCodeModifier: ViewModifier {
    @Binding var digit: String
    
    var textLimit = 1
    
    func limitText(_ upper: Int) {
        if digit.count > upper {
            self.digit = String(digit.prefix(upper))
        }
    }
    
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .onReceive(Just(digit)) { _ in limitText(textLimit) }
            .frame(width: 26, height: 48)
            .font(.largeTitle)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.clear, lineWidth: 1)
            )
            .overlay {
                if digit.isEmpty {
                    Rectangle().frame(width: 26, height: 2).background(.green)
                }
            }
    }
}

private func timeFormatted(_ totalSeconds: Int) -> String {
    let seconds: Int = totalSeconds % 60
    return String(format: "%02d", seconds)
}
