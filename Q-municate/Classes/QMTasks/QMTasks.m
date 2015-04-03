//
//  QMTasks.m
//  Q-municate
//
//  Created by Andrey on 24.11.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTasks.h"
#import "QMServicesManager.h"
#import "QMFacebook.h"

@implementation QMTasks

+ (void)taskLogin:(void(^)(BOOL success))completion  {
    
    dispatch_block_t success =^{
        
        [QM.chatService logIn:^(NSError *error) {
            completion(error ? NO : YES);
        }];
    };
    
    if (!QM.authService.isAuthorized) {
        
        if (QM.profile.type == QMProfileTypeFacebook) {
            
            QMFacebook *facebook = [[QMFacebook alloc] init];
            [facebook openSession:^(NSString *sessionToken) {
                // Singin or login
                [QM.authService logInWithFacebookSessionToken:sessionToken
                                                   completion:^(QBResponse *response,
                                                                QBUUser *tUser)
                 {
                     QM.profile.type = QMProfileTypeFacebook;
                     //Save profile to keychain
                     [QM.profile synchronizeWithUserData:tUser];
                 }];
            }];
            
        } else {
            
            [QM.authService logInWithUser:QM.profile.userData
                               completion:^(QBResponse *response,
                                            QBUUser *userProfile)
             {
                 if (response.success) {
                     
                     success();
                 }
             }];
        }
    }
    else {
        
        success();
    }
}

+ (void)taskFetchDialogsAndUsers:(void(^)(BOOL success))completion {
    
    [QM.chatService fetchAllDialogs:^(QBResponse *fetchAllDialogsResponse,
                                      NSArray *dialogObjects,
                                      NSSet *dialogsUsersIDs)
     {
         if (fetchAllDialogsResponse.success) {
             
             [QM.contactListService retrieveUsersWithIDs:dialogsUsersIDs.allObjects
                                              completion:^(QBResponse *retriveUsersResponse,
                                                           QBGeneralResponsePage *page,
                                                           NSArray *users)
              {
                  if (!retriveUsersResponse || retriveUsersResponse.success) {
                      
                      completion(YES);
                  }
                  else {
                      
                      completion(NO);
                  }
              }];
         }
         else {
             
             completion(NO);
         }
     }];
}

@end
