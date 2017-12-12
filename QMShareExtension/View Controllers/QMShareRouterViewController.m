//
//  QMShareRouterViewController.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/4/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMShareRouterViewController.h"
#import "QMShareTableViewController.h"
#import "QMShareTasks.h"

#import "QMShareEtxentionOperation.h"
#import "QMExtensionCache.h"
#import "QBChatDialog+QMShareItemProtocol.h"
#import "QBSettings+Qmunicate.h"

#import <Bolts/Bolts.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <Reachability/Reachability.h>
#import "QBUUser+QMShareItemProtocol.h"
#import "QBChatDialog+QMShareItemProtocol.h"
#import "UIImage+QM.h"
#import "QBChatAttachment+QMCustomParameters.h"
#import "UIAlertController+QM.h"
#import "QMConstants.h"

static const NSUInteger kQMUnauthorizedErrorCode = 401;

@interface QMShareRouterViewController()

<QMShareControllerDelegate,
QMShareEtxentionOperationDelegate>

@property (nonatomic, weak) QMShareEtxentionOperation *shareOperation;
@property (nonatomic, weak) QMShareTableViewController *shareTableViewController;
@property (nonatomic, weak) UIView *blurView;
@property (nonatomic, strong) id logoutObserver;

@property (nonatomic, copy) NSString *shareText;
@property (nonatomic, strong) QBChatAttachment *attachment;
@property (nonatomic, strong) Reachability *internetConnection;
@property (nonatomic, strong) NSDate *lastDialogsUpdateDate;

@property (nonatomic, strong) QMItemProviderResult *shareItem;

@end

@implementation QMShareRouterViewController

//MARK: - View Life Cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Quickblox settings
    [QBSettings configure];
    
    [self configureAppereance];
    [self configureReachability];
    
    __weak typeof(self) weakSelf = self;
    self.logoutObserver =
    [[QBDarwinNotificationCenter defaultCenter] addObserverForName:kQBLogoutNotification
                                                        usingBlock:^{
                                                            [weakSelf dismiss];
                                                        }];
    
    if (QBSession.currentSession.currentUser.ID) {
        
        [QMExtensionCache setLogsEnabled:NO];
        [self configureAndPresentShareTableViewController];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSLog(@"current user = %@", QBSession.currentSession.currentUser);
    if (QBSession.currentSession.currentUser.ID == 0) {
        
        dispatch_block_t completion = ^{
            
            NSString *errorText = NSLocalizedString(@"QM_EXT_SHARE_NOT_LOGGED_IN_ERROR", nil);
            NSError *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                                                 code:kQMUnauthorizedErrorCode
                                             userInfo:@{NSLocalizedDescriptionKey : errorText}];
            [self completeShare:error];
        };
        
        if (self.shareTableViewController.isBeingPresented) {
            [self.shareTableViewController dismissViewControllerAnimated:NO
                                                              completion:completion];
        }
        else {
            completion();
        }
    }
    else {
        
        if ([self.presentedViewController isKindOfClass:[QMShareTableViewController class]]) {
            [self updateDialogsDataSource];
        }
    }
}



//MARK: - Share Extension Control

- (void)completeShare:(nullable NSError *)error {
    
    NSString *status =
    error ?
    error.localizedDescription :
    NSLocalizedString(@"QM_EXT_SHARE_SUCESS_MESSAGE", nil);
    
    __weak typeof(self) weakSelf = self;
    
    [self presentAlertControllerWithStatus:status
                         withButtonHandler:^{
                             
                             __strong typeof(weakSelf) strongSelf = weakSelf;
                             
                             if (QBSession.currentSession.currentUser.ID &&
                                 error.code == kQMUnauthorizedErrorCode) {
                                 [strongSelf configureAndPresentShareTableViewController];
                             }
                             else {
                                 [strongSelf dismiss];
                             }
                         }];
}

- (void)dismiss {
    
    if (_blurView) {
        [_blurView removeFromSuperview];
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_block_t completion = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.extensionContext completeRequestReturningItems:nil
                                                 completionHandler:nil];
    };
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES
                                                         completion:completion];
    }
    else {
        completion();
    }
}

//MARK: - Cache

- (NSArray *)cachedDialogsForDataSource {
    return QMExtensionCache.chatCache.allDialogs;
}

- (NSArray *)cachedContactsForDataSource{
    
    NSMutableArray *userIDs = [NSMutableArray array];
    NSArray *allContactListItems = QMExtensionCache.contactsCache.allContactListItems;
    
    for (QBContactListItem *item in allContactListItems) {
        if (item.subscriptionState != QBPresenceSubscriptionStateNone) {
            [userIDs addObject:@(item.userID)];
        }
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.ID IN %@",userIDs];
    
    return [QMExtensionCache.usersCache.allUsers filteredArrayUsingPredicate:predicate];
}

//MARK: - QMShareTableViewController

- (void)presentShareViewControllerWithDialogs:(NSArray *)dialogsToShare
                                     contacts:(NSArray *)contactsToShare
                                   completion:(dispatch_block_t)completion {
    
    QMShareTableViewController *shareTableViewController =
    [QMShareTableViewController qm_shareTableViewControllerWithDialogs:dialogsToShare
                                                              contacts:contactsToShare];
    
    shareTableViewController.title = NSLocalizedString(@"QM_STR_SHARE", nil);
    
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:shareTableViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    
    [self presentViewController:navigationController
                       animated:YES
                     completion:completion];
    
    
    shareTableViewController.shareControllerDelegate = self;
    self.shareTableViewController = shareTableViewController;
}

//MARK: - QMShareControllerDelegate

- (void)didTapShareBarButtonWithSelectedItems:(NSArray *)selectedItems {
    
    NSParameterAssert(self.shareItem);
    
    if (self.shareOperation.isSending) {
        return;
    }
    
    if (!self.internetConnection.isReachable) {
        [self presentAlertControllerWithStatus:NSLocalizedString(@"QM_STR_LOST_INTERNET_CONNECTION", nil)
                             withButtonHandler:nil];
        return;
    }
    
    [self.shareTableViewController
     presentLoadingAlertControllerWithStatus:NSLocalizedString(@"QM_EXT_SHARE_SHARING_TITLE", nil)
     animated:YES
     withCompletion:nil];
    
    __weak typeof(self) weakSelf = self;
    
    QMShareEtxentionOperation *shareOperation =
    [QMShareEtxentionOperation operationWithID:NSBundle.mainBundle.bundleIdentifier
                                          text:self.shareItem.text
                                    attachment:self.shareItem.attachment
                                    recipients:selectedItems
                                    completion:^(NSError * _Nullable error,
                                                 BOOL completed)
     {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         [strongSelf.shareTableViewController
          dismissLoadingAlertControllerAnimated:YES
          withCompletion:^{
              if (error) {
                  NSString *errorText =
                  error.localizedDescription ?:
                  error.description ?:
                  NSLocalizedString(@"QM_EXT_SHARE_COMMON_ERROR", nil);
                  [strongSelf presentAlertControllerWithStatus:errorText
                                             withButtonHandler:nil];
              }
              else if (completed) {
                  [strongSelf completeShare:nil];
              }
          }];
         
     }];
    
    shareOperation.operationDelegate = self;
    [shareOperation start];
    
    self.shareOperation = shareOperation;
}

- (void)didCancelSharing {
    [self cancelShare];
}

- (void)didTapCancelBarButton {
    [self dismiss];
}

//MARK: - QMShareEtxentionOperationDelegate

- (BFTask <QBChatDialog *> *)taskForOperation:(QMShareEtxentionOperation *)operation
                                dialogForUser:(QBUUser *)user {
    
    return [QMShareTasks dialogForUser:user];
}

- (BFTask *)taskForOperation:(QMShareEtxentionOperation *)operation
                 sendMessage:(QBChatMessage *)message {
    
    return [self taskSendMessageViaRest:message];
}

- (BFTask<QBChatAttachment *> *)customTaskForOperation:(QMShareEtxentionOperation *)operation
                                      uploadAttachment:(QBChatAttachment *)attachment
                                         progressBlock:(QMAttachmentProgressBlock)progressBlock {
    
    if ([attachment.type isEqualToString:kQMAttachmentTypeLocation]) {
        return [BFTask taskWithResult:attachment];
    }
    return [self uploadAttachment:attachment progressBlock:progressBlock];
}


- (BFTask *)taskSendMessageViaRest:(QBChatMessage *)message {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        self.shareOperation.objectToCancel =
        (id <QMCancellableObject>)[QBRequest sendMessage:message
                                            successBlock:^(QBResponse * _Nonnull __unused response,
                                                           QBChatMessage * _Nonnull __unused tMessage)
                                   {
                                       
                                       [self postUpdateNotificationsForDialogWithID:tMessage.dialogID];
                                       
                                       [[self qmTaskSaveChangesForMessage:tMessage] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                                           [source setResult:tMessage];
                                           return nil;
                                       }];
                                   }
                                              errorBlock:^(QBResponse * _Nonnull response)
                                   {
                                       [source setError:response.error.error];
                                   }];
    });
}

- (BFTask <QBChatAttachment *> *)uploadAttachment:(QBChatAttachment *)attatchment
                                    progressBlock:(QMAttachmentProgressBlock)progressBlock {
    
    NSData *dataToSend = ^NSData *{
        
        if (attatchment.attachmentType == QMAttachmentContentTypeImage) {
            return attatchment.image.dataRepresentation;
        }
        
        return nil;
        
    }();
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        if (dataToSend) {
            self.shareOperation.objectToCancel =
            (id <QMCancellableObject>)[QBRequest TUploadFile:dataToSend
                                                    fileName:attatchment.name
                                                 contentType:attatchment.contentType
                                                    isPublic:NO
                                                successBlock:^(QBResponse * __unused  _Nonnull response,
                                                               QBCBlob * _Nonnull tBlob)
                                       {
                                           attatchment.ID = tBlob.UID;
                                           [source setResult:attatchment];
                                       }
                                                 statusBlock:^(QBRequest * _Nonnull request,
                                                               QBRequestStatus * _Nonnull status)
                                       {
                                           if (progressBlock) {
                                               progressBlock(status.percentOfCompletion);
                                           }
                                       }
                                       
                                                  errorBlock:^(QBResponse * _Nonnull response)
                                       {
                                           [source setError:response.error.error];
                                       }];
        }
        else if (attatchment.localFileURL) {
            self.shareOperation.objectToCancel =
            (id <QMCancellableObject>)[QBRequest uploadFileWithUrl:attatchment.localFileURL
                                                          fileName:attatchment.name
                                                       contentType:attatchment.contentType
                                                          isPublic:NO
                                                      successBlock:^(QBResponse * _Nonnull __unused response,
                                                                     QBCBlob * _Nonnull tBlob)
                                       {
                                           attatchment.ID = tBlob.UID;
                                           [source setResult:attatchment];
                                       }
                                                       statusBlock:nil
                                                        errorBlock:^(QBResponse * _Nonnull response)
                                       {
                                           [source setError:response.error.error];
                                       }];
        }
        else {
            NSAssert(NO, @"Should be set data or local URL");
        }
    });
}


//MARK: - Configuration

- (void)configureAppereance {
    
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        
        self.view.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blurEffectView.alpha = 0.6f;
        
        [self.view addSubview:blurEffectView];
        
        self.blurView = blurEffectView;
    }
    else {
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    
    [SVProgressHUD setViewForExtension:self.view];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
}

- (void)configureReachability {
    
    _internetConnection = [Reachability reachabilityForInternetConnection];
    __weak typeof(self) weakSelf = self;
    
    // setting unreachable block
    [_internetConnection setUnreachableBlock:^(Reachability __unused *reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // reachability block could possibly be called in background thread
            [weakSelf cancelShare];
            [weakSelf presentAlertControllerWithStatus:NSLocalizedString(@"QM_STR_LOST_INTERNET_CONNECTION", nil)
                                     withButtonHandler:nil];
        });
    }];
    
    [_internetConnection startNotifier];
}

- (void)configureAndPresentShareTableViewController {
    
    if ([self.presentedViewController isKindOfClass:[QMShareTableViewController class]]) {
        [self updateDialogsDataSource];
    }
    else {
        
        [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_EXT_SHARE_PROCESS_TITLE", nil)];
        
        dispatch_block_t presentShareController = ^{
            
            NSArray *dialogstoShare = [self cachedDialogsForDataSource];
            NSArray *contactsToShare = [self cachedContactsForDataSource];
            
            [self presentShareViewControllerWithDialogs:dialogstoShare
                                               contacts:contactsToShare
                                             completion:^{
                                                 [self updateDialogsDataSource];
                                                 [SVProgressHUD dismiss];
                                             }];
        };
        
        if (self.shareItem) {
            presentShareController();
        }
        else {
            [[self qmTaskGetShareItem] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                
                if (t.error) {
                    [self completeShare:t.error];
                }
                else {
                    presentShareController();
                }
                
                return nil;
            }];
        }
    }
}

//MARK: - Helpers

- (BFTask *)qmTaskSaveChangesForMessage:(QBChatMessage *)message {
    
    NSParameterAssert(message.dialogID);
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [QMExtensionCache.chatCache insertOrUpdateMessage:message
                                             withDialogId:message.dialogID
                                               completion:
         ^{
             QBChatDialog *dialog =
             [QMExtensionCache.chatCache dialogByID:message.dialogID];
             dialog.updatedAt = message.dateSent;
             
             [QMExtensionCache.chatCache insertOrUpdateDialog:dialog completion:^{
                 [source setResult:message];
             }];
         }];
    });
}


- (BFTask *)qmTaskGetShareItem {
    
    NSArray *inputItems = self.extensionContext.inputItems;
    NSLog(@"Input items = %@", inputItems);
    NSMutableArray *providers  = [NSMutableArray array];
    for (NSExtensionItem *item in inputItems) {
        [providers addObjectsFromArray:item.attachments];
    }
    NSLog(@"providers = %@", providers);
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_EXT_SHARE_PROCESS_TITLE", nil)];
    
    return [[QMShareTasks loadItemsForItemProviders:providers] continueWithExecutor:BFExecutor.mainThreadExecutor
                                                                   withSuccessBlock:
            ^id _Nullable(BFTask<NSArray<QMItemProviderResult *> *> * _Nonnull t) {
                NSLog(@"QMItemProviderResults = %@", t.result);
                QMItemProviderResult *result = t.result.firstObject;
                self.shareItem = result;
                
                return nil;
            }];
}

- (BFTask <NSArray <QBUUser *> *> *)taskUsersWithIDs:(NSArray *)userIDs {
    
    QBGeneralResponsePage *page =
    [QBGeneralResponsePage responsePageWithCurrentPage:1
                                               perPage:userIDs.count < 100 ? userIDs.count : 100];
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [QBRequest usersWithIDs:userIDs
                           page:page
                   successBlock:^(QBResponse *response,
                                  QBGeneralResponsePage *page,
                                  NSArray *users)
         {
             [source setResult:users];
             
         } errorBlock:^(QBResponse *response) {
             
             [source setError:response.error.error];
         }];
    });
}

- (BFTask <NSArray <QBChatDialog*>*> *)taskDialogsDataSource {
    
    if (!self.internetConnection.isReachable) {
        return [BFTask taskWithResult:nil];
    }
    return [[QMShareTasks taskFetchAllDialogsFromDate:self.lastDialogsUpdateDate] continueWithSuccessBlock:^id _Nullable(BFTask<NSArray<QBChatDialog *> *> * _Nonnull t) {
        self.lastDialogsUpdateDate = [NSDate date];
        return [BFTask taskWithResult:t.result];
    }];
}

- (void)presentAlertControllerWithStatus:(NSString *)errorStatus
                       withButtonHandler:(dispatch_block_t)buttonTapBlock {
    
    UIAlertController *alertController =
    [UIAlertController qm_infoAlertControllerWithStatus:errorStatus
                                         buttonTapBlock:buttonTapBlock];
    
    if (self.presentedViewController) {
        [self.presentedViewController presentViewController:alertController
                                                   animated:YES
                                                 completion:nil];
    }
    else {
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)updateDialogsDataSource {
    
    [[self taskDialogsDataSource] continueWithSuccessBlock:^id _Nullable(BFTask<NSArray<QBChatDialog *> *> * _Nonnull t) {
        if (t.result.count > 0) {
            [self.shareTableViewController.shareDataSource updateItems:t.result];
            [self.shareTableViewController.tableView reloadData];
        }
        return nil;
    }];
}

- (void)postUpdateNotificationsForDialogWithID:(NSString *)dialogID {
    
    NSParameterAssert(dialogID.length);
    
    NSString *observerName =
    [NSString stringWithFormat:@"%@:%@", kQMDidUpdateDialogNotificationPrefix, dialogID];
    
    [[QBDarwinNotificationCenter defaultCenter] postNotificationName:observerName];
    [[QBDarwinNotificationCenter defaultCenter] postNotificationName:kQMDidUpdateDialogsNotification];
}

- (void)cancelShare {
    
    [self.shareTableViewController dismissLoadingAlertControllerAnimated:YES
                                                          withCompletion:nil];
    [self.shareOperation cancel];
}

@end
