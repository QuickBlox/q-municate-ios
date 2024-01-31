//
//  Q_municateApp.swift
//  Q-municate
//
//  Created by Injoit on 11.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

@main
struct Q_municateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment (\.scenePhase) private var scenePhase
    
    @StateObject var viewModel: EnterViewModel = EnterViewModel()
    
    var body: some Scene {
        WindowGroup { 
            EnterView(viewModel: viewModel)
                .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .active:
                        if viewModel.authState != .checkVersion {
                            viewModel.startAuthFlow()
                        }
                    default:
                        print("default")
                    }
                }
        }
    }
}
