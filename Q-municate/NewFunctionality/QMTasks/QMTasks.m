//
//  QMTasks.m
//  Q-municate
//
//  Created by Andrey on 24.11.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTasks.h"
#import "QMApi.h"
#import "QMServicesManager.h"

@implementation QMTasks

+ (void)updateData:(void(^)(BOOL updateUserData))completion {
    
    void(^fetchData)(void) =^(void) {
        
        
        [[QMApi instance] subscribeToPushNotificationsForceSettings:NO
                                                           complete:^(BOOL subscribeToPushNotificationsSuccess)
         {
             if (!subscribeToPushNotificationsSuccess) {
                 
             }
         }];
    };
    
    [self taskLogin:^(BOOL loginSuccess) {
        
        if (loginSuccess) {
            
            [self taskFetchDialogsAndUsers:^(BOOL fetchDialogSuccess) {
                
                if (fetchDialogSuccess) {
                    
                    NSDictionary *push = [[QMApi instance] pushNotification];
                    
                    if (push != nil) {
                        
                        [[QMApi instance] openChatPageForPushNotification:push];
                        [[QMApi instance] setPushNotification:nil];
                    }
                    
                    if (!QM.profile.userData.imported) {
                        
                        [[QMApi instance] importFriendsFromFacebook];
                        [[QMApi instance] importFriendsFromAddressBook];
                        
                        
                        QM.profile.userData.imported = YES;
                        
                        [QM.profile updateUserWithCompletion:nil];
                        
                    }
                    else {
                        completion(YES);
                    }
                }
            }];
        }
        else {
            
        }
        
    }];
    
}

+ (void)taskLogin:(void(^)(BOOL success))completion  {
    
    if (!QM.authService.isAuthorized) {
        
        [QM.authService logInWithUser:QM.profile.userData
                           completion:^(QBResponse *response, QBUUser *userProfile)
         {
             if (response.success) {
                 
                 [QM.chatService logIn:^(NSError *error)
                  {
                      completion(!error);
                  }];
             }
             else {
                 completion(NO);
             }
         }];
    }
    else {
        completion(YES);
    }
}

+ (void)taskFetchDialogsAndUsers:(void(^)(BOOL success))completion {
    
    [QM.chatService fetchAllDialogs:^(QBResponse *fetchAllDialogsResponse, NSArray *dialogObjects, NSSet *dialogsUsersIDs)
     {
         if (fetchAllDialogsResponse.success) {
             
             [QM.contactListService retrieveUsersWithIDs:dialogsUsersIDs.allObjects
                                              completion:^(QBResponse *retriveUsersResponse, QBGeneralResponsePage *page, NSArray *users)
              {
                  if (retriveUsersResponse.success) {
                      
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
