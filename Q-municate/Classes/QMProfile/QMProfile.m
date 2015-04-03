//
//  QMProfile.m
//  Q-municate
//
//  Created by Andrey Ivanov on 24.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMProfile.h"
#import <Security/Security.h>
#import "SSKeychain.h"

NSString *const kQMUserDataKey = @"userData";
NSString *const kQMUserAgreementAcceptedKey = @"userAgreementAccepted";
NSString *const kQMPushNotificationsEnabled = @"pushNotificationsEnabled";
NSString *const kQMUserProfileType = @"userProfileType";

@implementation QMProfile

+ (instancetype)profile {
    
    QMProfile *profile = [[QMProfile alloc] init];
    
    return profile;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self loadProfile];
    }
    return self;
}

#pragma mark - Keychain

- (void)keychainQuery:(void(^)(SSKeychainQuery *query))keychainQueryBlock {
    
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    NSString *service = [NSString stringWithFormat:@"%@.service", bundleIdentifier];
    NSString *account = [NSString stringWithFormat:@"%@.account", bundleIdentifier];
    
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = service;
    query.account = account;
    
    keychainQueryBlock(query);
}

- (BOOL)synchronize {
    
    __weak __typeof(self)weakSelf = self;
    __block BOOL success = NO;
    
    NSAssert(self.userData, @"Need user data");
    
    [self keychainQuery:^(SSKeychainQuery *query) {
        
        query.passwordObject = weakSelf;
        NSError *error = nil;
        success = [query save:&error];
    }];
    
    return success;
}

- (BOOL)synchronizeWithUserData:(QBUUser *)user {
    
    NSAssert(user, @"Need user data");
    self.userData = user;
    BOOL success = [self synchronize];
    
    return success;
}

- (void)loadProfile {
    
    __block QMProfile *profile = nil;
    
    [self keychainQuery:^(SSKeychainQuery *query) {
        
        NSError *error = nil;
        BOOL success = [query fetch:&error];
        
        if (success) {
            profile = (id)query.passwordObject;
        }
    }];
    
    self.pushNotificationsEnabled = profile.pushNotificationsEnabled;
    self.userAgreementAccepted = profile.userAgreementAccepted;
    self.userData = profile.userData;
    self.type = profile.type;
}

- (BOOL)clearProfile {
    
    __block BOOL success = NO;
    
    [self keychainQuery:^(SSKeychainQuery *query) {
        
        NSError *error = nil;
        success = [query deleteItem:&error];
    }];
    
    return success;
}

#pragma mark - Server API

- (void)changePassword:(NSString *)newPassword
            completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    
    QBUUser *updateUser = self.userData;
    
    updateUser.oldPassword = updateUser.password;
    updateUser.password = newPassword;
    
    [QBRequest updateUser:updateUser
             successBlock:^(QBResponse *response,
                            QBUUser *userData)
     {
         userData.password = updateUser.password;
         weakSelf.userData = userData;
         [weakSelf synchronize];
         
         if (completion) {
             completion(YES);
         }
         
     } errorBlock:^(QBResponse *response) {
         
         if (completion) {
             completion(NO);
         }
     }];
}

- (void)saveOnServer:(void (^)(BOOL success))completion {
    
    NSString *password = self.userData.password;
    self.userData.password = nil;
    
    if (self.userData.customDataChanged) {
        [self.userData syncronize];
    }
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest updateUser:self.userData
             successBlock:^(QBResponse *response,
                            QBUUser *updatedUser)
     {
         
         updatedUser.password = password;
         weakSelf.userData = updatedUser;
         [weakSelf synchronize];
         
         if (completion) {
             completion(YES);
         };
         
     } errorBlock:^(QBResponse *response) {
         
         if (completion) {
             completion(NO);
         }
     }];
}

- (void)updateUserImage:(UIImage *)userImage
               progress:(void (^)(float progress))progress
             completion:(void (^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    
    QBUUser *userData = [self.userData copy];
    
    void (^updateUserProfile)(NSString *) =^(NSString *publicUrl) {
        
        if (publicUrl.length > 0) {
            
        }
        
        NSString *password = userData.password;
        userData.password = nil;
        
        [QBRequest updateUser:userData
                 successBlock:^(QBResponse *response,
                                QBUUser *updatedUser)
         {
             updatedUser.password = password;
             weakSelf.userData = updatedUser;
             [weakSelf synchronize];
             
             completion(YES);
             
         } errorBlock:^(QBResponse *response) {
             
             completion(NO);
         }];
    };
    
    if (userImage) {
        
        NSData *uploadFile = UIImageJPEGRepresentation(userImage, 0.4);
        
        [QBRequest TUploadFile:uploadFile
                      fileName:@"userImage"
                   contentType:@"image/jpeg"
                      isPublic:YES
                  successBlock:^(QBResponse *response,
                                 QBCBlob *blob)
         {
             updateUserProfile(blob.publicUrl);
             
         } statusBlock:^(QBRequest *request,
                         QBRequestStatus *status)
         {
             progress(status.percentOfCompletion);
             
         } errorBlock:^(QBResponse *response) {
             
             completion(NO);
         }];
    }
    else {
        
        completion(NO);
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]){
        
        self.userData = [aDecoder decodeObjectForKey:kQMUserDataKey];
        self.userAgreementAccepted = [aDecoder decodeBoolForKey:kQMUserAgreementAcceptedKey];
        self.pushNotificationsEnabled = [aDecoder decodeBoolForKey:kQMPushNotificationsEnabled];
        self.type = [aDecoder decodeIntegerForKey:kQMUserProfileType];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.userData forKey:kQMUserDataKey];
    [aCoder encodeBool:self.userAgreementAccepted forKey:kQMUserAgreementAcceptedKey];
    [aCoder encodeBool:self.pushNotificationsEnabled forKey:kQMPushNotificationsEnabled];
    [aCoder encodeInteger:self.type forKey:kQMUserProfileType];
}

@end