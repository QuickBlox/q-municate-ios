//
//  EnterView.swift
//  Q-municate
//
//  Created by Injoit on 19.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxUIKit
import QuickBloxDomain
import Quickblox
import QuickBloxLog
import Combine

struct EnterViewConstant {
    static let regexUserName = "^(?=[a-zA-Z])[-a-zA-Z_ ]{3,49}(?<! )$"
    static let regexDialogName = "^(?=.{3,60}$)(?!.*([\\s])\\1{2})[\\w\\s]+$"
    static let aiApiKey = ""
}

public struct TabIndex: Hashable {
    public var title: String
    public var systemIcon: String
    
    public init(title: String, systemIcon: String) {
        self.title = title
        self.systemIcon = systemIcon
    }
}

public extension TabIndex {
    static let dialogs = TabIndex(title: "Dialogs",
                                  systemIcon: "message.fill")
    static let settings = TabIndex(title: "Settings",
                                   systemIcon: "gearshape.fill")
}

struct EnterView: View {
    @ObservedObject var viewModel: EnterViewModel
    
    @State public var theme: AppTheme = appThemes[UserDefaults.standard.integer(forKey: "Theme")]
    @State private var selectedTabIndex: TabIndex = .dialogs
    @State private var tabBarVisibility: Visibility = .visible
    @State private var showAppVersionAlert: Bool = false
    @State private var showNoInternetAlert: Bool = false
    @State private var isCheckUpdate: Bool = false
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    init(viewModel: EnterViewModel) {
        self.viewModel = viewModel
        setupFeatures()
        
        QuickBloxUIKit.syncState
            .receive(on: RunLoop.main)
            .sink { syncState in
                if syncState == QuickBloxDomain.SyncState.syncing(stage: .unauthorized),
                   viewModel.isAutoLogin == false {
                    viewModel.logOut()
                    viewModel.authState = .unAuthorized
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupTabView(with content: AnyView, isNavigationBarPresented: Binding<Bool>) -> AnyView {
        let dialogsTab = content
            .toolbarBackground(theme.color.mainBackground, for: .tabBar)
            .toolbarBackground(tabBarVisibility, for: .tabBar)
            .tabItem {
                Label(TabIndex.dialogs.title, systemImage: TabIndex.dialogs.systemIcon)
            }
            .tag(TabIndex.dialogs)
        
        let settingsTab = CreateProfileView(viewModel, theme: theme)
            .toolbarBackground(theme.color.mainBackground, for: .tabBar)
            .toolbarBackground(tabBarVisibility, for: .tabBar)
            .tabItem {
                Label(TabIndex.settings.title, systemImage: TabIndex.settings.systemIcon)
            }
            .tag(TabIndex.settings)
        
        let tabView = TabView(selection: $selectedTabIndex) {
            if UIDevice.current.userInterfaceIdiom != .phone {
                Spacer()
            }
            dialogsTab
            settingsTab
        }
            .onChange(of: selectedTabIndex) { newValue in
                isNavigationBarPresented.wrappedValue = (newValue == .dialogs)
            }
            .accentColor(theme.color.mainElements)
        
        return AnyView(tabView)
    }
    
    var body: some View {
        ZStack {
            theme.color.mainBackground.ignoresSafeArea()
            
            switch viewModel.authState {
            case .unAuthorized:
                EnterPhoneNumberView(theme: theme, viewModel: viewModel).onAppear {
                    selectedTabIndex = .dialogs
                }
                
            case .authorized:
                if viewModel.user?.name.isEmpty == true ||
                    viewModel.user?.name.isValid(regexes: [EnterViewConstant.regexUserName]) == false {
                    CreateProfileView(viewModel, theme: theme)
                } else {
                    QuickBloxUIKit.dialogsView(onModifyContent: { content, isNavigationBarPresented in
                        setupTabView(with: content, isNavigationBarPresented: isNavigationBarPresented)
                    })
                    .onAppear {
                        theme = appThemes[UserDefaults.standard.integer(forKey: "Theme")]
                        setupSettings()
                    }
                    
                    .onChange(of: viewModel.error) { newValue in
                        showNoInternetAlert = newValue == AuthError.networkError.localizedDescription
                    }
                    
                    .enterPhoneFailureAlert(isPresented: $showNoInternetAlert,
                                            message: viewModel.error,
                                            onDismiss: {
                        viewModel.error = ""
                        showNoInternetAlert = false
                    }, settings: EnterPhoneNumberScreenSettings(theme))
                    
                }
            case .checkVersion:
                ZStack {
                    Color("backgroundLaunch").ignoresSafeArea()
                    ZStack {
                        Image("qmunicate-logo")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .scaledToFit()
                            .frame(width: 178, height: 154)
                        VStack {
                            Spacer()
                            
                            Text(theme.qmunicateString.poweredByQuickblox)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
                .onChange(of: viewModel.isAvailableUpdateAppVersion) { newValue in
                    if newValue == true {
                        showAppVersionAlert = true
                    }
                }
                .if(showAppVersionAlert == true && viewModel.lastVersion.isEmpty == false) { view in
                    view.appVersionAlert(theme: theme, isPresented: $showAppVersionAlert,
                                         lastVersion: viewModel.lastVersion,
                                         onUpdate: { update in
                        update == true ? viewModel.openAppStore() : viewModel.startAuthFlow()
                    })
                }
            }
        }
    }
    
    private func setupFeatures() {
        QBSettings.logLevel = .nothing
        QuickBloxLog.LogSettings.type = .nothing
        
        
        QuickBloxUIKit.feature.ai.apiKey = EnterViewConstant.aiApiKey
        QuickBloxUIKit.feature.ai.ui = QuickBloxUIKit.AIUISettings(theme)
        QuickBloxUIKit.feature.forward.enable = true
        QuickBloxUIKit.feature.reply.enable = true
        QuickBloxUIKit.feature.regex.userName = EnterViewConstant.regexUserName
        QuickBloxUIKit.feature.regex.dialogName = EnterViewConstant.regexDialogName
    }
    
    private func setupSettings() {
        // Setup Custom Theme
        QuickBloxUIKit.settings.theme = theme
        
        // Hide backButton for Dialogs Screen
        QuickBloxUIKit.settings.dialogsScreen.header.leftButton.hidden = true
        
        // Setup Background Image for Dialog Screen
        QuickBloxUIKit.settings.dialogScreen.backgroundImage = Image("dialogBackground")
        QuickBloxUIKit.settings.dialogScreen.backgroundImageColor = theme.color.divider
    }
}

struct AppVersionAlert: ViewModifier {
    @State private var settings: UpdateVersionAlertSettings
    @Binding var isPresented: Bool
    let lastVersion: String
    let onUpdate: (_ isUpdate: Bool) -> Void
    
    init(theme: AppTheme,
         isPresented:  Binding<Bool>,
         lastVersion: String,
         onUpdate: @escaping (_: Bool) -> Void) {
        self.settings = UpdateVersionAlertSettings(theme)
        _isPresented = isPresented
        self.lastVersion = lastVersion
        self.onUpdate = onUpdate
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            content.blur(radius: 12.0)
                .disabled(true)
                .alert(settings.newVersion, isPresented: $isPresented) {
                    Button(settings.skip, action: {
                        onUpdate(false)                    })
                    Button(settings.update, action: {
                        onUpdate(true)
                    })
                } message: {
                    Text(settings.updateToVersion + " " + lastVersion)
                }
        }
    }
}

extension View {
    func appVersionAlert(
        theme: AppTheme,
        isPresented: Binding<Bool>,
        lastVersion: String,
        onUpdate: @escaping (_ isUpdate: Bool) -> Void
    ) -> some View {
        self.modifier(AppVersionAlert(theme: theme,
                                      isPresented: isPresented,
                                      lastVersion: lastVersion,
                                      onUpdate: onUpdate))
    }
}
