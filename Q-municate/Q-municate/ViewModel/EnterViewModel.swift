//
//  EnterViewModel.swift
//  Q-municate
//
//  Created by Injoit on 12.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import Combine

struct EnterViewModelConstant {
    static let allowedPhoneNumChar = "0123456789+"
    static let networkErrorCode = 17020
    static let invalidPhoneNumberCode = 17042
    static let invalidVerificationCode = 17044
    static let noInternetConnectionCode = -1009
    static let totalResendTime = 60
    static let smsCodeCount = 6
}

enum AuthState {
    case authorized
    case unAuthorized
    case checkVersion
}

final class EnterViewModel: ObservableObject {
    @Published public var avatar: UIImage? = nil
    @Published public var isLoadingAvatar: Bool = false
    @Published public var userName = ""
    @Published public var error = ""
    @Published public var verifyCodeError = ""
    @Published public var isValidUserName = false
    @Published public var isProcessing: Bool = false
    @Published public var isAutoLogin: Bool = false
    
    @Published public var isVerifyCodeProcessing: Bool = false
    @Published public var isAvailableUpdateAppVersion: Bool = false
    var lastVersion: String = ""
    
    private var isNeedUpdateAvatar: Bool = false
    
    public var isExistingImage: Bool {
        if let user {
            return user.avatarPath.isEmpty == false
        } else {}
        return false
    }
    
    @Published var isPhoneNumberVerifiedSuccess: Bool = false
    
    @Published var authState: AuthState = .checkVersion
    var countryPhoneCodes: [CountryPhoneCode] = []
    @Published var phoneNumber: String = ""
    @Published var selectedCountry: CountryPhoneCode = CountryPhoneCode.defaultCountryPhoneCode
    @Published var smsCode: String = ""
    @Published var isCodeSendingBlocked: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var resendCodeTimer: Timer?
    @Published var totalResendTime = EnterViewModelConstant.totalResendTime
    
    var user: User? {
        didSet {
            if user != nil {
                authState = .authorized
                userName = user?.name ?? ""
            } else {
                authState = .unAuthorized
                userName = ""
                avatar = nil
            }
        }
    }
    
    init() {
        
        checkAppStoreUpdateAvailable()
        
        countryPhoneCodes = CountryPhoneCode.getCodes()
        
        if let loadedCountryPhoneCode = loadCountryPhoneCode() {
            selectedCountry = loadedCountryPhoneCode
        }
        
        isProfileNameValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValidUserName, on: self)
            .store(in: &cancellables)
    }
    
    func openAppStore() {
        let api = API()
        api.openAppStore()
        authState = api.currentUser() == nil ? .unAuthorized : .authorized
    }
    
    func checkAppStoreUpdateAvailable() {
        let api = API()
        do {
            try api.isUpdateAvailable { [weak self] (lastVersion, _) in
                if let lastVersion, lastVersion.isEmpty == false {
                    print("lastVersion: \(lastVersion)")
                    DispatchQueue.main.async {
                        self?.lastVersion = lastVersion
                        self?.isAvailableUpdateAppVersion = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.startAuthFlow()
                    }
                }
            }
        } catch {
            startAuthFlow()
            print(error)
        }
    }
    
    func startAuthFlow() {
        let api = API()
        if let currentUser = api.currentUser() {
            user = currentUser
            getAvatar()
        } else {
            authState = .unAuthorized
            return
        }
        if isAutoLogin == true {
            return
        }
        isAutoLogin = true
        api.autoLogin { [weak self] user, error in
            self?.error = ""
            if let user {
                self?.isAutoLogin = false
                self?.user = user
            } else if let error {
                if error._code == EnterViewModelConstant.networkErrorCode ||
                    error._code == EnterViewModelConstant.noInternetConnectionCode {
                    DispatchQueue.main.async {
                        self?.error = AuthError.networkError.localizedDescription
                    }
                    self?.isAutoLogin = false
                    return
                }
                self?.isAutoLogin = false
                self?.logOut()
                self?.authState = .unAuthorized
            }
        }
    }
    
    func selectCountry(_ country: CountryPhoneCode) {
        selectedCountry = country
    }
    
    func verifyPhoneNumber() {
        if isProcessing == true { return }
        
        guard phoneNumber.isEmpty == false else {
            error = AuthError.noPhoneNumberEntered.localizedDescription
            return
        }
        isProcessing = true
        smsCode = ""
        
        let phoneNumStr = (selectedCountry.dial_code + phoneNumber).filter(EnterViewModelConstant.allowedPhoneNumChar.contains)
        
        let api = API()
        api.verifyPhoneNumber(phoneNumStr) { [weak self] error in
            self?.smsCode = ""
            self?.activateResendCodeTimer()
            self?.isProcessing = false
            if let error {
                if error._code == EnterViewModelConstant.invalidPhoneNumberCode {
                    DispatchQueue.main.async {
                        self?.error = AuthError.invalidPhoneNumber.localizedDescription
                    }
                    
                } else if error._code == EnterViewModelConstant.networkErrorCode ||
                            error._code == EnterViewModelConstant.noInternetConnectionCode {
                    DispatchQueue.main.async {
                        self?.error = AuthError.networkError.localizedDescription
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self?.error = error.localizedDescription
                    }
                    
                }
                self?.invalidateResendCodeTimer()
                return
            }
            self?.error = ""
            DispatchQueue.main.async {
                self?.isPhoneNumberVerifiedSuccess = true
            }
            
            if let loadedCountryPhoneCode = self?.loadCountryPhoneCode(),
               loadedCountryPhoneCode.dial_code != self?.selectedCountry.dial_code {
                self?.setCountryPhoneCode()
            } else {
                self?.setCountryPhoneCode()
            }
        }
    }
    
    func setupUserInfo() {
        userName = user?.name ?? ""
        if avatar != nil, isNeedUpdateAvatar == false { return }
        getAvatar()
    }
    
    func resetUserInfo() {
        isNeedUpdateAvatar = false
        userName = user?.name ?? ""
        getAvatar()
    }
    
    func setupDefaultInfo() {
        phoneNumber = ""
        
        if let loadedCountryPhoneCode = loadCountryPhoneCode() {
            selectedCountry = loadedCountryPhoneCode
            return
        }
        selectedCountry = CountryPhoneCode.defaultCountryPhoneCode
    }
    
    private func loadCountryPhoneCode() -> CountryPhoneCode? {
        let decoder = JSONDecoder()
        if let savedCountryPhoneCode = UserDefaults.standard.object(forKey: FirebaseAPIConstant.countryPhoneCodeKey) as? Data,
           let loadedCountryPhoneCode = try? decoder.decode(CountryPhoneCode.self, from: savedCountryPhoneCode) {
            return loadedCountryPhoneCode
        }
        return nil
    }
    
    private func setCountryPhoneCode() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(selectedCountry) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: FirebaseAPIConstant.countryPhoneCodeKey)
        }
    }
    
    func verifyCode() {
        if smsCode.count != EnterViewModelConstant.smsCodeCount {
            verifyCodeError = AuthError.unvalidCode.localizedDescription
            return
        }
        
        isVerifyCodeProcessing = true
        verifyCodeError = ""
        
        let api = API()
        api.verifyCode(smsCode) { [weak self] user, error in
            if let error {
                if error._code == EnterViewModelConstant.invalidVerificationCode{
                    self?.verifyCodeError = AuthError.verifyCodeError.localizedDescription
                } else {
                    self?.verifyCodeError = error.localizedDescription
                }
                self?.isVerifyCodeProcessing = false
                return
            }
            self?.isPhoneNumberVerifiedSuccess = false
            self?.isVerifyCodeProcessing = false
            self?.smsCode = ""
            self?.invalidateResendCodeTimer()
            self?.error = ""
            self?.user = user
            self?.setupDefaultInfo()
        }
    }
    
    func logOut() {
        let api = API()
        api.logOut { [weak self] error in
            if let error {
                self?.error = error.localizedDescription
                return
            }
            self?.user = nil
            self?.isPhoneNumberVerifiedSuccess = false
        }
    }
    
    public func handleOnSelect(_ uiImage: UIImage) {
        isNeedUpdateAvatar = true
        avatar = uiImage
    }
    
    public func removeExistingImage() {
        guard let user, let blobId = UInt(user.avatarPath) else { return }
        isProcessing = true
        isNeedUpdateAvatar = true
        let api = API()
        api.deleteAvatar(blobId) { [weak self] error in
            if error != nil {
                self?.isProcessing = false
                return
            }
            self?.avatar = nil
            self?.updateUser()
        }
    }
    
    public func updateUser() {
        if isValidUserName == false { return }
        if user?.name == userName, isNeedUpdateAvatar == false { return }
        isProcessing = true
        let api = API()
        let update = UpdateUserParameters(name: userName, avatar: avatar)
        api.updateUser(update) { [weak self] user, error in
            if let error {
                self?.error = error.localizedDescription
                self?.isProcessing = false
                return
            }
            self?.error = ""
            self?.user = user
            self?.isProcessing = false
        }
    }
    
    private func getAvatar() {
        guard let user = user,
              user.avatarPath.isEmpty == false,
              let blobId = UInt(user.avatarPath) else { return }
        
        isLoadingAvatar = true
        
        let api = API()
        api.getAvatar(blobId) { [weak self] avatar, error in
            if let error {
                self?.error = error.localizedDescription
                self?.isProcessing = false
                self?.isLoadingAvatar = false
                return
            }
            if let avatar {
                DispatchQueue.main.async {
                    self?.avatar = avatar
                    self?.isLoadingAvatar = false
                }
            }
            self?.error = ""
            self?.isProcessing = false
        }
    }
    
    private func activateResendCodeTimer() {
        totalResendTime = EnterViewModelConstant.totalResendTime
        isCodeSendingBlocked = true
        resendCodeTimer = Timer.scheduledTimer(timeInterval: 1,
                                               target: self,
                                               selector: #selector(updateResendTime),
                                               userInfo: nil,
                                               repeats: true)
    }
    
    @objc func updateResendTime() {
        if totalResendTime != 0 {
            totalResendTime -= 1
        } else {
            invalidateResendCodeTimer()
        }
    }
    
    @objc func invalidateResendCodeTimer() {
        resendCodeTimer?.invalidate()
        resendCodeTimer = nil
        isCodeSendingBlocked = false
    }
}

private extension EnterViewModel {
    var isProfileNameValidPublisher: AnyPublisher<Bool, Never> {
        $userName
            .map { userName in
                return userName.isValid(regexes: [EnterViewConstant.regexUserName])
            }
            .eraseToAnyPublisher()
    }
}

struct UpdateUserParameters {
    let name: String
    let avatar: UIImage?
}

struct FileContent {
    let data: Data
    let name: String
    let mimeType: String
    let isPublic: Bool
}
