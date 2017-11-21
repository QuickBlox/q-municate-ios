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

static const NSUInteger kQMUnauthorizedErrorCode = 401;

@interface QMShareRouterViewController()

<QMShareControllerDelegate,
QMShareEtxentionOperationDelegate>

@property (nonatomic, weak) QMShareEtxentionOperation *shareOperation;
@property (nonatomic, strong) QMShareTableViewController *shareTableViewController;
@property (nonatomic, weak) UIView *blurView;
@property (strong, nonatomic) id logoutObserver;

@property (nonatomic, copy) NSString *shareText;
@property (nonatomic, strong) QBChatAttachment *attachment;
@property (strong, nonatomic) Reachability *internetConnection;
@property (strong, nonatomic) NSDate *lastDialogsUpdateDate;
@end

@implementation QMShareRouterViewController

- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    // Quickblox settings
    [QBSettings configureForQmunicate];
    [QBSettings setLogLevel:QBLogLevelDebug];
    
    [self configureAppereance];
    
    if (!QBSession.currentSession.currentUser.ID) {
        return;
    }
    
    [self configureReachability];
    
    // [self loadAttachments];
    [QMExtensionCache setLogsEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    self.logoutObserver =
    [[QBDarwinNotificationCenter defaultCenter] addObserverForName:kQBLogoutNotification
                                                        usingBlock:^{
                                                            [weakSelf dismiss];
                                                        }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSLog(@"current user = %@", QBSession.currentSession.currentUser);
    if (!QBSession.currentSession.currentUser.ID) {
        
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
        [self loadAttachments];
        [self updateDataSource];
    }
}

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


- (void)loadAttachments {
    
    NSArray *inputItems = self.extensionContext.inputItems;
    NSLog(@"Input items = %@", inputItems);
    NSMutableArray *providers  = [NSMutableArray array];
    for (NSExtensionItem *item in inputItems) {
        [providers addObjectsFromArray:item.attachments];
    }
    NSLog(@"providers = %@", providers);
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_EXT_SHARE_PROCESS_TITLE", nil)];
    
    [[QMShareTasks loadItemsForItemProviders:providers] continueWithExecutor:BFExecutor.mainThreadExecutor
                                                                   withBlock:
     ^id _Nullable(BFTask<NSArray<QMItemProviderResult *> *> * _Nonnull t) {
         
         [SVProgressHUD dismiss];
         
         if (t.error) {
             [self completeShare:t.error];
         }
         else {
             NSLog(@"QMItemProviderResults = %@", t.result);
             
             QMItemProviderResult *result = t.result.firstObject;
             
             self.attachment = result.attachment;
             self.shareText = result.text;
             
             NSArray *dialogsToShare = [self dialogsForDataSource];
             NSArray *contactsToShare = [self contactsForDataSource];
             
             self.shareTableViewController =
             [QMShareTableViewController qm_shareTableViewControllerWithDialogs:dialogsToShare
                                                                       contacts:contactsToShare];
             
             self.shareTableViewController.title = NSLocalizedString(@"QM_STR_SHARE", nil);
             
             UINavigationController *navigationController =
             [[UINavigationController alloc] initWithRootViewController:self.shareTableViewController];
             
             navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
             
             [SVProgressHUD setViewForExtension:navigationController.view];
             
             [self presentViewController:navigationController
                                animated:YES
                              completion:nil];
             
             
             self.shareTableViewController.shareControllerDelegate = self;
         }
         
         [SVProgressHUD dismiss];
         
         return nil;
     }];
}

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
                                 [strongSelf loadAttachments];
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

- (NSArray *)dialogsForDataSource {
    return QMExtensionCache.chatCache.allDialogs;
}

- (NSArray *)contactsForDataSource {
    
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


//MARK: - QMShareControllerDelegate

- (void)didTapShareBarButtonWithSelectedItems:(NSArray *)selectedItems {
    
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
                                          text:self.shareText
                                    attachment:self.attachment
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
                                            successBlock:^(QBResponse * _Nonnull __unused response, QBChatMessage * _Nonnull __unused tMessage) {
                                                [QMExtensionCache.chatCache insertOrUpdateMessage:tMessage withDialogId:message.dialogID completion:^{
                                                    [source setResult:tMessage];
                                                }];
                                            }
                                              errorBlock:^(QBResponse * _Nonnull response) {
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
                                                 statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nonnull status) {
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

//MARK: - Helpers

- (void)updateDataSource {
    
    [[QMShareTasks taskFetchAllDialogsFromDate:self.lastDialogsUpdateDate] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        self.lastDialogsUpdateDate = [NSDate date];
        
        [self.shareTableViewController.shareDataSource updateItems:t.result];
        [self.shareTableViewController.tableView reloadData];
        return nil;
    }];
}

- (void)presentAlertControllerWithStatus:(NSString *)errorStatus
                       withButtonHandler:(dispatch_block_t)buttonTapBlock {
    
    UIAlertController *alertController = [UIAlertController qm_infoAlertControllerWithStatus:errorStatus
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


- (void)cancelShare {
    
    [self.shareTableViewController dismissLoadingAlertControllerAnimated:YES
                                                          withCompletion:nil];
    [self.shareOperation cancel];
}

@end
