//
//  QMMessageIntentHandler.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/24/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMMessageIntentHandler.h"

#import <Intents/Intents.h>
#import <QMServices.h>
#import "QMSiriHelper.h"

@interface QMMessageIntentHandler() <INSendMessageIntentHandling>

@end

@implementation QMMessageIntentHandler

//MARK: - INSendMessageIntentHandling

// Implementation of resolution methods to provide additional information about the intent
- (void)resolveRecipientsForSendMessage:(INSendMessageIntent *)intent withCompletion:(void (^)(NSArray<INPersonResolutionResult *> *resolutionResults))completion {
    
    QBUUser *user = [QMSiriHelper instance].currentUser;
    
    if (user == nil) {
        completion(@[[INPersonResolutionResult unsupported]]);
        return;
    }
    
    if (intent.groupName.length) {
        [[QMSiriHelper instance] groupDialogWithName:intent.groupName completionBlock:^(QBChatDialog *dialog) {
            
            if (dialog != nil) {
                completion(@[[INPersonResolutionResult notRequired]]);
                return;
            }
            else {
                completion(@[[INPersonResolutionResult unsupported]]);
                return;
            }
        }];
        
    }
    else {
        
        NSArray<INPerson *> *recipients = intent.recipients;
        // If no recipients were provided we'll need to prompt for a value.
        if (recipients.count == 0) {
            completion(@[[INPersonResolutionResult needsValue]]);
            return;
        }
        
        // Implementation of the contact matching logic for creating an array of matching contacts
        
        NSMutableArray<INPersonResolutionResult *> *resolutionResults = [NSMutableArray array];
        
        dispatch_group_t matchingContactsGroup = dispatch_group_create();
        
        for (INPerson *recipient in recipients) {
            
            dispatch_group_enter(matchingContactsGroup);
            
            [[QMSiriHelper instance] contactsMatchingName:recipient.displayName completionBlock:^(NSArray *matchingContacts) {
                
                if (matchingContacts.count > 1) {
                    // We need Siri's help to ask user to pick one from the matches.
                    [resolutionResults addObject:[INPersonResolutionResult disambiguationWithPeopleToDisambiguate:matchingContacts]];
                    
                }
                else if (matchingContacts.count == 1) {
                    // We have exactly one matching contact
                    [resolutionResults addObject:[INPersonResolutionResult successWithResolvedPerson:matchingContacts.firstObject]];
                }
                else {
                    // We have no contacts matching the description provided
                    [resolutionResults addObject:[INPersonResolutionResult unsupported]];
                }
                dispatch_group_leave(matchingContactsGroup);
            }];
        }
        
        dispatch_group_notify(matchingContactsGroup, dispatch_get_main_queue(), ^{
            completion(resolutionResults);
        });
    }
}
- (void)resolveGroupNameForSendMessage:(INSendMessageIntent *)intent
                        withCompletion:(void (^)(INStringResolutionResult *resolutionResult))completion{
    
}
- (void)resolveContentForSendMessage:(INSendMessageIntent *)intent withCompletion:(void (^)(INStringResolutionResult *resolutionResult))completion {
    
    NSString *text = intent.content;
    
    if (text.length > 0) {
        completion([INStringResolutionResult successWithResolvedString:text]);
    } else {
        completion([INStringResolutionResult needsValue]);
    }
}

- (void)confirmSendMessage:(INSendMessageIntent *)intent completion:(void (^)(INSendMessageIntentResponse *response))completion {
    
    // Verify user is authenticated and the app is ready to send a message.
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
    QBUUser *user = [[QMSiriHelper instance] currentUser];
    INSendMessageIntentResponse *response;
    
    if (user != nil) {
        response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeReady
                                                        userActivity:userActivity];
    }
    else {
        userActivity.userInfo = @{@"Error" : @"No user"};
        response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeFailureRequiringAppLaunch
                                                        userActivity:userActivity];
    }
    
    completion(response);
}

// Handle the completed intent (required).

- (void)handleSendMessage:(INSendMessageIntent *)intent completion:(void (^)(INSendMessageIntentResponse *response))completion {
    
    void(^messageSendingBlock)(NSString *) = ^(NSString *dialogID){
        
        NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
        
        if (dialogID != nil) {
            
            NSUInteger senderID = [QMSiriHelper instance].currentUser.ID;
            QBChatMessage *message = [QBChatMessage message];
            message.text = intent.content;
            message.senderID = senderID;
            message.markable = YES;
            message.deliveredIDs = @[@(senderID)];
            message.readIDs = @[@(senderID)];
            message.dialogID = dialogID;
            message.dateSent = [NSDate date];
            
            [QBRequest sendMessage:message successBlock:^(QBResponse * _Nonnull response, QBChatMessage * _Nonnull createdMessage) {
                
                INSendMessageIntentResponse *successResponse = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeSuccess
                                                                                                    userActivity:userActivity];
                completion(successResponse);
                
            } errorBlock:^(QBResponse * _Nonnull response) {
                
                userActivity.userInfo = @{@"Error" : response.error.error.localizedDescription ?: @"Request error"};
                INSendMessageIntentResponse *errorResponse = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeFailure
                                                                                                  userActivity:userActivity];
                completion(errorResponse);
            }];
        }
        else {
            userActivity.userInfo = @{@"Error" : @"No dialog"};
            INSendMessageIntentResponse *errorResponse = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeFailure
                                                                                              userActivity:userActivity];
            completion(errorResponse);
        }
    };
    
    // Implementation of the application logic for sending a message.
    if (intent.groupName.length) {
        [[QMSiriHelper instance] groupDialogWithName:intent.groupName completionBlock:^(QBChatDialog *dialog) {
            if (dialog != nil) {
                messageSendingBlock(dialog.ID);
            }
        }];
    }
    else {
        
        NSString *recipientID = [intent.recipients firstObject].customIdentifier;
        [[QMSiriHelper instance] dialogIDForUserWithID:recipientID.integerValue completionBlock:messageSendingBlock];
    }
}

@end
