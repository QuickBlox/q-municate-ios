//
//  FirebaseAPI.swift
//  Q-municate
//
//  Created by Injoit on 28.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import FirebaseAuth

struct FirebaseAPIConstant {
    static let verificationIDKey = "kVerificationID"
    static let countryPhoneCodeKey = "kCountryPhoneCode"
}


struct FirebaseAPI {

    func verify(phoneNumber: String, completion: @escaping (Error?) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
          if let error = error {
              completion(error)
            return
          }
            if let verificationID {
                UserDefaults.standard.set(verificationID, forKey: FirebaseAPIConstant.verificationIDKey)
                completion(nil)
            }
        }
    }

    func verify(code: String, completion: @escaping (_ projectID: String?,
                                                     _ accessToken: String?,
                                                     _ error: Error?) -> Void) {
        guard let verificationID = UserDefaults.standard.string(forKey: FirebaseAPIConstant.verificationIDKey) else {
            completion(nil, nil, AuthError.noVerificationID)
            return
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error {
                completion(nil, nil, error)
            }
            if let authResult {
                authResult.user.getIDToken { token, error in
                    if let error {
                        completion(nil, nil, error)
                    }
                    if let token, let projectID = Auth.auth().app?.options.projectID {
                        completion(projectID, token, nil)
                    } else {
                        completion(nil, nil, error)
                    }
                }
            }
        }
    }
    
    func autoLogin(with completion: @escaping (_ projectID: String?,
                                               _ accessToken: String?,
                                               _ error: Error?) -> Void) {
        guard let phoneUser = Auth.auth().currentUser else {
            completion(nil, nil, nil)
            return }
        phoneUser.getIDToken { token, error in
            if let error {
                completion(nil, nil, error)
            }
            if let token, let projectID = Auth.auth().app?.options.projectID {
                completion(projectID, token, nil)
            } else {
                completion(nil, nil, error)
            }
        }
    }
}
