//
//  QuickbloxAPI.swift
//  Q-municate
//
//  Created by Injoit on 28.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import Quickblox

struct QuickbloxAPI {
    
    func logInWithFirebase(_ projectID: String,
                           accessToken: String,
                           completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        QBRequest.logIn(withFirebaseProjectID: projectID, accessToken: accessToken, successBlock: { response, tUser in
            guard let password = QBSession.current.sessionDetails?.token else {
                completion(nil, response.error?.error)
                return
            }
            tUser.password = password
            completion(User(tUser), nil)
        }, errorBlock: { response in
            completion(nil, response.error?.error)
        })
    }
    
    func connect(withUserID userId: UInt, completion: @escaping (Bool) -> Void) {
        guard let token = QBSession.current.sessionDetails?.token else {
            completion(false)
            return
        }
        QBChat.instance.connect(withUserID: userId, password: token) { error in
            if error != nil {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func disconnect(_ completion: @escaping (Error?) -> Void) {
        QBChat.instance.disconnect() {_ in
            QBRequest.logOut(successBlock: { response in
                completion(nil)
            }) { response in
                guard let error = response.error?.error else {
                    completion(nil)
                    return
                }
                completion(error)
            }
        }
    }
    
    private func updateUser(_ updateUserParameter: QBUpdateUserParameters, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        QBRequest.updateCurrentUser(updateUserParameter, successBlock: { response, user in
            completion(User(user), nil)
        }, errorBlock: { response in
            completion(nil, response.error?.error)
        })
    }
    
    func updateUser(_ update: UpdateUserParameters, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        
        if let avatar = update.avatar {
            var compressionQuality: CGFloat = 1.0
            let maxFileSize: Int = 10 * 1024 * 1024 // 10MB in bytes
            var imageData = avatar.jpegData(compressionQuality: compressionQuality)
            
            while let data = imageData, data.count > maxFileSize && compressionQuality > 0.0 {
                compressionQuality -= 0.1
                imageData = avatar.jpegData(compressionQuality: compressionQuality)
            }
            
            guard let imageData else {
                return
            }
            
            // Sending attachment.
            DispatchQueue.main.async(execute: {
                let file = FileContent(data: imageData, name: update.name, mimeType: "image/jpeg", isPublic: true)
                
                self.upload(file: file, completion: { blob in
                    let parameters = QBUpdateUserParameters()
                    if let blobId = blob?.id {
                        parameters.blobID = blobId
                    }
                    parameters.fullName = update.name
                    self.updateUser(parameters) { user, error in
                        if let error {
                            completion(nil, error)
                        } else {
                            completion(user, nil)
                        }
                    }
                })
            })
        } else {
            let parameters = QBUpdateUserParameters()
            parameters.fullName = update.name
            self.updateUser(parameters) { user, error in
                if let error {
                    completion(nil, error)
                } else {
                    completion(user, nil)
                }
            }
        }
    }
    
    private func upload(file content: FileContent, completion: @escaping (_ uploadedBlob: QBCBlob?) -> Void) {
        QBRequest.tUploadFile(content.data,
                              fileName: content.name,
                              contentType: content.mimeType,
                              isPublic: content.isPublic) { _, blob in
            completion(blob)
        } statusBlock: { _,_ in
            //TODO: add progress handler
        } errorBlock: { response in
            completion(nil)
        }
    }
    
    func getAvatar(_ blobId: UInt, completion: @escaping (_ avatar: UIImage?, _ error: Error?) -> Void) {
        QBRequest.blob(withID: blobId, successBlock: { (response, blob) in
            guard let blobUID = blob.uid else {return}
            QBRequest.downloadFile(withUID: blobUID, successBlock: { (response, fileData)  in
                if let image = UIImage(data: fileData) {
                    completion(image, nil)
                }
            }, statusBlock: { (request, status) in
                
            }, errorBlock: { (response) in
                completion(nil, response.error?.error)
            })
        }, errorBlock: { (response) in
            completion(nil, response.error?.error)
        })
    }
    
    func deleteAvatar(_ blobId: UInt, completion: @escaping (_ error: Error?) -> Void) {
        QBRequest.deleteBlob(withID: blobId) {(response) in
            completion(nil)
        } errorBlock: { (response) in
            completion(response.error?.error)
        }
    }
 
    func configure() {
        Quickblox.initWithApplicationId(0,
                                        authKey: "",
                                        authSecret: "",
                                        accountKey: "")
        
        QBSettings.carbonsEnabled = true
        QBSettings.autoReconnectEnabled = true
    }
    
    func currentUser() -> User? {
        if let currentUser = QBSession.current.currentUser {
            return User(currentUser)
        } else {
            return nil
        }
    }
}
