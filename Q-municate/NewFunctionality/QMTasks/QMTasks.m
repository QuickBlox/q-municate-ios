//
//  QMTasks.m
//  Q-municate
//
//  Created by Andrey on 24.11.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTasks.h"
#import "QMServicesManager.h"

@implementation QMTasks

+ (void)taskLogin:(void(^)(BOOL success))completion  {
    
    if (!QM.authService.isAuthorized) {
        
        [QM.authService logInWithUser:QM.profile.userData
                           completion:^(QBResponse *response, QBUUser *userProfile)
         {
             if (response.success) {
                 
                 [QM.chatService logIn:^(NSError *error) {
                     
                     completion(!error);
                 }];
             }
             else {
                 
                 completion(NO);
             }
         }];
    }
    else {
        
        [QM.chatService logIn:^(NSError *error) {
            
            completion(!error);
        }];
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
