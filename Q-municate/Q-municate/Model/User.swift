//
//  User.swift
//  Q-municate
//
//  Created by Injoit on 15.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox

public struct User {
    public let id: String
    
    /// Display name of the User.
    ///
    /// > Note: Returns an empty string by default
    public var name: String = ""
    public var avatarPath: String = ""
    public var lastRequestAt: Date = Date(timeIntervalSince1970: 0)
    
    public var isCurrent: Bool = false
    
    public init(id: String,
                name: String,
                isCurrent: Bool = false,
                lastRequestAt: Date =
                Date(timeIntervalSince1970: 0)) {
        self.id = id
        self.name = name
        self.isCurrent = isCurrent
        self.lastRequestAt = lastRequestAt
    }
}

extension User {
   init (_ value: QBUUser) {
       id = String(value.id)
       name = value.fullName ?? ""
       if (value.blobID > 0) {
           avatarPath = String(value.blobID)
       }
       lastRequestAt = value.lastRequestAt ??
       Date(timeIntervalSince1970: 0)
       isCurrent = QBSession.current.currentUserID == value.id
   }
}
