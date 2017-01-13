//
//  QMCore.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMCore.h"
#import <Reachability.h>
#import "QMFacebook.h"
#import "QMNotification.h"
#import "QMTasks.h"
#import <SVProgressHUD.h>
#import <SDWebImageManager.h>
#import "QMCallManager.h"
#import "QMCallManager.h"
#import <Intents/Intents.h>
#import "NSString+QMTransliterating.h"
#import "QMHelpers.h"

static NSString *const kQMLastActivityDateKey = @"last_activity_date";
static NSString *const kQMErrorKey = @"errors";
static NSString *const kQMBaseErrorKey = @"base";

static NSString *const kQMContactListCacheNameKey = @"q-municate-contacts";

@interface QMCore ()

@property (strong, nonatomic) BFTask *restLoginTask;
@property (strong, nonatomic) NSMutableOrderedSet *cachedVocabularyStrings;

@end

@implementation QMCore

+ (instancetype)instance {
    
    static QMCore *core = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        core = [[self alloc] init];
    });
    
    return core;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Contact list service init
        [QMContactListCache setupDBWithStoreNamed:kQMContactListCacheNameKey applicationGroupIdentifier:[self appGroupIdentifier]];
        _contactListService = [[QMContactListService alloc] initWithServiceManager:self cacheDataSource:self];
        [_contactListService addDelegate:self];
        
        // Profile init
        _currentProfile = [QMProfile currentProfile];
        
        // Users cache init
        [self.usersService loadFromCache];
        
        // Vocabulary string cache init
        _cachedVocabularyStrings = [NSMutableOrderedSet orderedSet];
        
        // managers
        _contactManager = [[QMContactManager alloc] initWithServiceManager:self];
        _chatManager = [[QMChatManager alloc] initWithServiceManager:self];
        _pushNotificationManager = [[QMPushNotificationManager alloc] initWithServiceManager:self];
        _callManager = [[QMCallManager alloc] initWithServiceManager:self];
        
        // Reachability init
        [self configureReachability];
        [self.chatService addDelegate:self];
    }
    
    return self;
}

- (void)configureReachability {
    
    _internetConnection = [Reachability reachabilityForInternetConnection];
    
    // setting reachable block
    @weakify(self);
    [_internetConnection setReachableBlock:^(Reachability __unused *reachability) {
        
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            // reachability block could possibly be called in background thread
            [self login];
        });
    }];
    
    // setting unreachable block
    [_internetConnection setUnreachableBlock:^(Reachability __unused *reachability) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // reachability block could possibly be called in background thread
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_LOST_INTERNET_CONNECTION", nil)];
        });
    }];
    
    [_internetConnection startNotifier];
}

#pragma mark - Error handling

- (NSString *)errorStringFromResponseStatus:(QBResponseStatusCode)statusCode {
    
    switch (statusCode) {
        case QBResponseStatusCodeServerError:
            return NSLocalizedString(@"QM_STR_BAD_GATEWAY_ERROR", nil);
            
        case QBResponseStatusCodeUnknown:
            return NSLocalizedString(@"QM_STR_CONNECTION_NETWORK_ERROR", nil);
            
        case QBResponseStatusCodeUnAuthorized:
            return NSLocalizedString(@"QM_STR_INCORRECT_USER_DATA_ERROR", nil);
            
        default:
            return nil;
    }
}

- (void)loopErrorArray:(NSArray *)errorArray forMutableString:(NSMutableString *)mutableString {
    
    for (NSString *errStr in errorArray) {
        
        if (errStr != nil) {
            
            [mutableString appendString:errStr];
            [mutableString appendString:@", "];
        }
    }
    
    [mutableString deleteCharactersInRange:NSMakeRange(mutableString.length - 2, 2)];
}

- (NSString *)appGroupIdentifier {
    return @"group.com.quickblox.qmunicate";
}

- (void)handleErrorResponse:(QBResponse *)response {
    NSAssert(!response.success, @"Error handling is valid only for unsuccessful response.");
    
    NSString *errorMessage = nil;
    
    if (![self isInternetConnected]) {
        
        errorMessage = NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil);
    }
    else {
        
        errorMessage = [self errorStringFromResponseStatus:response.status];
        
        if (errorMessage == nil) {
            
            id errorReasons = response.error.reasons[kQMErrorKey];
            
            NSMutableString *mutableString = [NSMutableString new];
            if ([errorReasons isKindOfClass:[NSArray class]]) {
                
                [self loopErrorArray:errorReasons forMutableString:mutableString];
            }
            else if ([errorReasons isKindOfClass:[NSDictionary class]]) {
                
                for (NSString *key in [errorReasons allKeys]) {
                    
                    if (![key isEqualToString:kQMBaseErrorKey]) {
                        
                        [mutableString appendString:key];
                    }
                    
                    [mutableString appendString:@" "];
                    [self loopErrorArray:errorReasons[key] forMutableString:mutableString];
                    [mutableString appendString:@"\n"];
                }
                
                [mutableString deleteCharactersInRange:NSMakeRange(mutableString.length - 1, 1)];
            }
            
            errorMessage = [mutableString copy];
        }
    }
    
    [SVProgressHUD showErrorWithStatus:errorMessage];
}

#pragma mark - Auth methods

- (BFTask *)login {
    
    BOOL needUpdateSessionToken = NO;
    
    if (self.currentProfile.accountType != QMAccountTypeEmail) {
        // due to chat requiring token as a password for any account types
        // but email, wee need to update session token first if it has been expired
        // just perform any request first
        needUpdateSessionToken = [self sessionTokenHasExpiredOrNeedCreate];
    }
    
    if ([self isAuthorized]
        && ![QBChat instance].isConnected) {
        
        if (needUpdateSessionToken) {
            
            @weakify(self);
            return [[QMTasks taskFetchAllData] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
                
                @strongify(self);
                // updating password with new token
                [QBSession currentSession].currentUser.password = [QBSession currentSession].sessionDetails.token;
                return [self.chatService connect];
            }];
        }
        
        return [self.chatService connect];
    }
    else if (![QBChat instance].isConnected) {
        
        if (needUpdateSessionToken) {
            
            @weakify(self);
            return [[QMTasks taskAutoLogin] continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull __unused task) {
                
                @strongify(self);
                // updating password with new token
                [QBSession currentSession].currentUser.password = [QBSession currentSession].sessionDetails.token;
                return [self.chatService connect];
            }];
        }
        
        // doing a parallel login
        
        // setting password to current session user
        if (self.currentProfile.accountType == QMAccountTypeEmail) {
            
            [QBSession currentSession].currentUser.password = self.currentProfile.userData.password;
        }
        else {
            
            [QBSession currentSession].currentUser.password = [QBSession currentSession].sessionDetails.token;
        }
        
        // saving rest login task cause we need to login in REST
        // only once per app living
        BFTask *restLoginTask = [QMTasks taskAutoLogin];
        BFTask *chatConnectTask = [self.chatService connect];
        
        return [BFTask taskForCompletionOfAllTasks:@[restLoginTask, chatConnectTask]];
    }
    
    return nil;
}

- (BFTask *)logout {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    @weakify(self);
    [[self.pushNotificationManager unSubscribeFromPushNotifications] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused t) {
        
        [super logoutWithCompletion:^{
            
            @strongify(self);
            if (self.currentProfile.accountType == QMAccountTypeFacebook) {
                
                [QMFacebook logout];
            }
            else if (self.currentProfile.accountType == QMAccountTypeDigits) {
                
                [[Digits sharedInstance] logOut];
            }
            
            [[SDWebImageManager sharedManager].imageCache clearMemory];
            [[SDWebImageManager sharedManager].imageCache clearDisk];
            
            // clearing contact list cache and memory storage
            [[QMContactListCache instance] deleteContactList:nil];
            [self.contactListService.contactListMemoryStorage free];
            
            [self.currentProfile clearProfile];
            [source setResult:nil];
        }];
        
        return nil;
    }];
    
    return source.task;
}

#pragma mark QMContactListServiceCacheDelegate delegate

- (void)cachedContactListItems:(QMCacheCollection)block {
    
    [[QMContactListCache instance] contactListItems:block];
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs {
    
    [super chatService:chatService didAddChatDialogsToMemoryStorage:chatDialogs];
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatDialog *_Nullable dialog, NSDictionary<NSString *,id> *__unused _Nullable bindings) {
        return dialog.type == QBChatDialogTypeGroup && dialog.name.length;
    }];
    
    if ([chatDialogs filteredArrayUsingPredicate:predicate].count > 0) {
        [self.cachedVocabularyStrings addObjectsFromArray:[chatDialogs valueForKey:@"name"]];
        [self updateVocabulary];
    }
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
    
    [super chatService:chatService didAddChatDialogToMemoryStorage:chatDialog];
    
    if (chatDialog.type == QBChatDialogTypeGroup && chatDialog.name.length) {
        [self.cachedVocabularyStrings addObject:chatDialog.name];
        [self updateVocabulary];
    }
}

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
    
    [super chatService:chatService didDeleteChatDialogWithIDFromMemoryStorage:chatDialogID];
    
    QBChatDialog *chatDialog = [self.chatService.dialogsMemoryStorage chatDialogWithID:chatDialogID];
    
    if (chatDialog.type == QBChatDialogTypeGroup && chatDialog.name.length) {
        [self.cachedVocabularyStrings removeObject:chatDialog.name];
        [self updateVocabulary];
    }
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)contactList {
    
    [[QMContactListCache instance] insertOrUpdateContactListItemsWithContactList:contactList completion:nil];
    
    // load users if needed
    [self.usersService getUsersWithIDs:[self.contactListService.contactListMemoryStorage userIDsFromContactList]];
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBUUser * _Nullable user, NSDictionary<NSString *,id> *__unused _Nullable bindings) {
        return user.fullName.length > 0;
    }];
    
    NSArray *friendNames = [[self.contactManager.friends filteredArrayUsingPredicate:predicate] valueForKey:@"fullName"];
    [self.cachedVocabularyStrings addObjectsFromArray:friendNames];
    
    [self updateVocabulary];
}

#pragma mark - Helpers

- (BOOL)isInternetConnected {
    
    return [self.internetConnection isReachable];
}

- (BOOL)sessionTokenHasExpiredOrNeedCreate {
    
    NSDate *date = [QBSession currentSession].sessionExpirationDate;
    
    if (date != nil) {
        
        NSDate *currentDate = [NSDate date];
        NSTimeInterval interval = [currentDate timeIntervalSinceDate:date];
        
        return interval > 0;
    }
    
    return YES;
}


- (void)updateVocabulary {
    
    // INVocabulary(Siri) is supported in ios 10 +
    if (!(iosMajorVersion() < 10)) {
        return;
    }
    
    if (self.cachedVocabularyStrings.count > 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *  _Nullable string, NSDictionary<NSString *,id> *__unused _Nullable bindings) {
            return ![string canBeConvertedToEncoding:NSISOLatin1StringEncoding];
        }];
        
        //Searching names, that have non-latin characters
        NSOrderedSet *nonLatinNames = [self.cachedVocabularyStrings.copy filteredOrderedSetUsingPredicate:predicate];
        
        for (NSString *string in nonLatinNames) {
            
            NSString *transliteratedString = [string qm_transliteratedString];
            //Adding transliterated names to vocabulary strings
            [self.cachedVocabularyStrings addObject:transliteratedString];
        }
        
        [[INVocabulary sharedVocabulary] setVocabularyStrings:self.cachedVocabularyStrings
                                                       ofType:INVocabularyStringTypeContactName];
    }
}

@end
