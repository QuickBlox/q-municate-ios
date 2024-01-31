//
//  Errors.swift
//  Q-municate
//
//  Created by Injoit on 11.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

enum AuthError: Error {
    case noPhoneNumberEntered
    case invalidPhoneNumber
    case noVerificationID
    case unvalidCode
    case verifyCodeError
    case networkError
}

extension AuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noPhoneNumberEntered:
            return "Please enter a phone number"
        case .noVerificationID:
            return "Error fetching verification id"
        case .unvalidCode:
            return "Please enter a valid code"
        case .verifyCodeError:
            return "Code verification error"
        case .invalidPhoneNumber:
            return "The phone number provided is incorrect. Please enter the right phone number"
        case .networkError:
            return "No Internet Connection"
        }
    }
}

