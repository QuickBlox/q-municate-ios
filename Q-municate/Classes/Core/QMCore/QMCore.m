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
#import "QMImageLoader.h"
#import "QMCallManager.h"
#import <Intents/Intents.h>
#import "NSString+QMTransliterating.h"

#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseAuth/FirebaseAuth.h>

static NSString *const kQMLastActivityDateKey = @"last_activity_date";
static NSString *const kQMErrorKey = @"errors";
static NSString *const kQMBaseErrorKey = @"base";

static NSString *const kQMContactListCacheNameKey = @"q-municate-contacts";
static NSString *const kQMOpenGraphCacheNameKey = @"q-municate-open-graph";

@interface QMCore () <QMAuthServiceDelegate>

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

+ (QMContactListService *)contactListService {
    return QMCore.instance.contactListService;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Contact list service init
        [QMContactListCache setupDBWithStoreNamed:kQMContactListCacheNameKey
                       applicationGroupIdentifier:[self appGroupIdentifier]];
        
        _contactListService = [[QMContactListService alloc] initWithServiceManager:self
                                                                   cacheDataSource:self];
        [_contactListService addDelegate:self];
        //Open Graph Service init
        [QMOpenGraphCache setupDBWithStoreNamed:kQMOpenGraphCacheNameKey
                     applicationGroupIdentifier:[self appGroupIdentifier]];
        
        _openGraphService = [[QMOpenGraphService alloc] initWithServiceManager:self
                                                               cacheDataSource:self];
        [_openGraphService addDelegate:self];
        
        // Profile init
        _currentProfile = [QMProfile currentProfile];
        // Vocabulary string cache init
        _cachedVocabularyStrings = [NSMutableOrderedSet orderedSet];
        
        // managers
        _contactManager = [[QMContactManager alloc] initWithServiceManager:self];
        _chatManager = [[QMChatManager alloc] initWithServiceManager:self];
        _pushNotificationManager = [[QMPushNotificationManager alloc] initWithServiceManager:self];
        _callManager = [[QMCallManager alloc] initWithServiceManager:self];
        
        [self.authService addDelegate:self];
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

//MARK: - Error handling

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
    
    if (errorMessage.length > 0) {
        [SVProgressHUD showErrorWithStatus:errorMessage];
    }
}

//MARK: - Auth methods

- (BFTask *)login {
    
    return [[QMTasks taskAutoLogin]
            continueWithSuccessBlock:^id(BFTask<QBUUser *> *task) {
                return [self.chatService connectWithUserID:task.result.ID password:task.result.password];
            }];
}

- (BFTask *)logout {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    //TODO: Need move to single object
    [self.cachedVocabularyStrings removeAllObjects];
    [[INVocabulary sharedVocabulary] setVocabularyStrings:self.cachedVocabularyStrings
                                                   ofType:INVocabularyStringTypeContactName];
    
    [[self.pushNotificationManager unregisterFromPushNotificationsAndUnsubscribe:YES]
     continueWithBlock:^id(BFTask * __unused t)
     {
         [super logoutWithCompletion:^{
             
             if (self.currentProfile.accountType == QMAccountTypeFacebook) {
                 [QMFacebook logout];
             }
             else if (self.currentProfile.accountType == QMAccountTypePhone) {
                 [[FIRAuth auth] signOut:nil];
             }
             // Clearing contact list cache and memory storage
             [[QMContactListCache instance] deleteContactList:nil];
             [self.contactListService.contactListMemoryStorage free];
             [self.openGraphService.memoryStorage free];
             [self.chatService.chatAttachmentService removeAllMediaFiles];
             
             dispatch_group_t logoutGroup = dispatch_group_create();
             
             dispatch_group_enter(logoutGroup);
             [[QMImageLoader instance].imageCache clearDiskOnCompletion:^{
                 [[QMImageLoader instance].imageCache clearMemory];
                 dispatch_group_leave(logoutGroup);
             }];
             
             dispatch_group_enter(logoutGroup);
             [QMOpenGraphCache.instance deleteAllOpenGraphItemsWithCompletion:^{
                 dispatch_group_leave(logoutGroup);
             }];
             
             dispatch_group_notify(logoutGroup, dispatch_get_main_queue(), ^{
                 [self.currentProfile clearProfile];
                 [source setResult:nil];
             });
         }];
         
         return nil;
         
     }];
    
    return source.task;
}

//MARK: QMContactListServiceCacheDelegate delegate

- (void)cachedContactListItems:(QMCacheCollection)block {
    block([QMContactListCache.instance allContactListItems]);
}

//MARK: - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs {
    
    [super chatService:chatService didAddChatDialogsToMemoryStorage:chatDialogs];
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatDialog *_Nullable dialog, NSDictionary<NSString *,id> *__unused _Nullable bindings) {
        return dialog.type == QBChatDialogTypeGroup && dialog.name.length;
    }];
    
    NSArray *filteredDialogs = [chatDialogs filteredArrayUsingPredicate:predicate];
    if (filteredDialogs.count > 0) {
        [self.cachedVocabularyStrings addObjectsFromArray:[filteredDialogs valueForKey:@"name"]];
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

//MARK: - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)__unused contactListService
      contactListDidChange:(QBContactList *)contactList {
    
    [[QMContactListCache instance] insertOrUpdateContactListItemsWithContactList:contactList completion:nil];
    // load users if needed
    NSArray<NSNumber *> *IDs = [self.contactListService.contactListMemoryStorage userIDsFromContactList];
    
    [[self.usersService getUsersWithIDs:IDs] continueWithSuccessBlock:^id _Nullable(BFTask<NSArray<QBUUser *> *> * _Nonnull t) {
        
        NSParameterAssert(IDs.count == t.result.count);
        
        NSPredicate *predicate =
        [NSPredicate predicateWithBlock:^BOOL(QBUUser *user, NSDictionary<NSString *,id> *__unused bindings) {
            return user.fullName.length > 0;
        }];
        
        NSArray *friendNames = [[self.contactManager.friends filteredArrayUsingPredicate:predicate] valueForKey:@"fullName"];
        
        if (friendNames.count) {
            [self.cachedVocabularyStrings addObjectsFromArray:friendNames];
            [self updateVocabulary];
        }
        
        return nil;
    }];
}

//MARK: QMOpenGraphCacheDataSource

- (nullable QMOpenGraphItem *)cachedOpenGraphItemWithID:(NSString *)ID {
    
    return [QMOpenGraphCache.instance openGrapItemWithID:ID];
}

//MARK:QMOpenGraphServiceDelegate

- (void)openGraphSerivce:(QMOpenGraphService *) __unused openGraphSerivce
didAddOpenGraphItemToMemoryStorage:(QMOpenGraphItem *)openGraphItem {
    
    [QMOpenGraphCache.instance insertOrUpdateOpenGraphItem:openGraphItem
                                                completion:nil];
}

- (void)openGraphSerivce:(QMOpenGraphService *) __unused openGraphSerivce
           hasFaviconURL:(NSURL *)url
              completion:(dispatch_block_t)completion {
    
    [QMImageLoader.instance downloadImageWithURL:url
                                       transform:nil
                                         options:SDWebImageHighPriority
                                        progress:nil
                                       completed:^(UIImage * __unused image,
                                                   UIImage * __unused transfomedImage,
                                                   NSError * __unused error,
                                                   SDImageCacheType __unused cacheType,
                                                   BOOL __unused finished,
                                                   NSURL * __unused imageURL) {
                                           completion();
                                       }];
}

- (void)openGraphSerivce:(QMOpenGraphService *)__unused openGraphSerivce
             hasImageURL:(NSURL *)url
              completion:(dispatch_block_t)completion {
    
    [QMImageLoader.instance downloadImageWithURL:url
                                       transform:nil
                                         options:SDWebImageHighPriority
                                        progress:nil
                                       completed:^(UIImage * __unused image,
                                                   UIImage * __unused transfomedImage,
                                                   NSError * __unused error,
                                                   SDImageCacheType __unused cacheType,
                                                   BOOL __unused finished,
                                                   NSURL * __unused imageURL) {
                                           completion();
                                       }];
}

//MARK: - Helpers

- (BOOL)isInternetConnected {
    
    return [self.internetConnection isReachable];
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

- (void)authServiceDidLogOut:(QMAuthService *)__unused authService {
    
    NSParameterAssert(QBSession.currentSession.tokenHasExpired == YES);
    NSParameterAssert(QBSession.currentSession.sessionDetails.token == nil);
}

- (void)authService:(QMAuthService *)__unused authService
   didLoginWithUser:(QBUUser *)__unused user {
    
    if (iosMajorVersion() > 9) {
        [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus __unused status) {
            
        }];
    }
}

@end
