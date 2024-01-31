//
//  API.swift
//  Q-municate
//
//  Created by Injoit on 11.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct APIConstant {
    static let appID = ""
}

struct API {
    private let firebase: FirebaseAPI = FirebaseAPI()
    private let quickblox: QuickbloxAPI = QuickbloxAPI()
    
    enum AppVersionCheckError: Error {
        case invalidResponse, invalidBundleInfo
    }

    @discardableResult
    func isUpdateAvailable(completion: @escaping (_ lastVersion: String?, _ error: Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw AppVersionCheckError.invalidBundleInfo
        }
            
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                if let error = error { throw error }
                
                guard let data = data else { throw AppVersionCheckError.invalidResponse }
                            
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                            
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any],
                      let lastVersion = result["version"] as? String else {
                    throw AppVersionCheckError.invalidResponse
                }
                completion(lastVersion > currentVersion ? lastVersion : nil, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
        return task
    }
    
    func openAppStore() {
        if let url = URL(string: "https://itunes.apple.com/us/app/apple-store/id\(APIConstant.appID)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func verifyPhoneNumber(_ phoneNumber: String, completion: @escaping (Error?) -> Void) {
        firebase.verify(phoneNumber: phoneNumber) { error in
            completion(error)
        }
    }

    func verifyCode(_ verificationCode: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        firebase.verify(code: verificationCode) { projectID, accessToken, error in
            guard let projectID = projectID,
                  let accessToken = accessToken  else {
                completion(nil, error)
                return
            }
            quickblox.logInWithFirebase(projectID, accessToken: accessToken) { user, error in
                if let user {
                    completion(user, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
    func autoLogin(with completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        firebase.autoLogin { projectID, accessToken, error in
            guard let projectID = projectID,
                  let accessToken = accessToken  else {
                completion(nil, error)
                return
            }
            quickblox.logInWithFirebase(projectID, accessToken: accessToken) { user, error in
                if let user {
                    completion(user, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
    func logOut(_ completion: @escaping (Error?) -> Void) {
        quickblox.disconnect { error in
            completion(error)
        }
    }
    
    func updateUser(_ update: UpdateUserParameters, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        quickblox.updateUser(update) { user, error in
            if let error {
                completion(nil, error)
            } else {
                completion(user, nil)
            }
        }
    }
    
    func getAvatar(_ blobId: UInt, completion: @escaping (_ avatar: UIImage?, _ error: Error?) -> Void) {
        quickblox.getAvatar(blobId) { avatar, error in
            if let error {
                completion(nil, error)
            } else {
                completion(avatar, nil)
            }
        }
    }
    
    func deleteAvatar(_ blobId: UInt, completion: @escaping (_ error: Error?) -> Void) {
        quickblox.deleteAvatar(blobId) { error in
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func configure() {
        quickblox.configure()
    }
    
    func currentUser() -> User? {
       return quickblox.currentUser()
    }
}
