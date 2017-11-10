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

static const CGFloat kDismissTimeOut = 1.5;

@interface QMShareRouterViewController()

<QMShareControllerDelegate,
QMShareEtxentionOperationDelegate>

@property (nonatomic, strong) QMShareEtxentionOperation *shareOperation;
@property (nonatomic, strong) QMShareTableViewController *shareTableViewController;

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
    
    [self configureAppereance];
    [self configureReachability];
    
    [self loadAttachments];
    
    __weak typeof(self) weakSelf = self;
    self.logoutObserver =
    [[QBDarwinNotificationCenter defaultCenter] addObserverForName:kQBLogoutNotification
                                                        usingBlock:^{
                                                            [weakSelf dismiss];
                                                        }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!QBSession.currentSession.currentUser.ID) {
        
        dispatch_block_t completion = ^{
            
            NSString *errorText = NSLocalizedString(@"QM_EXT_SHARE_NOT_LOGGED_IN_ERROR", nil);
            NSError *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                                                 code:0
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
        [self updateDataSource];
    }
}

- (void)configureAppereance {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.alpha = 0.6;
    
    [SVProgressHUD setViewForExtension:self.view];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
}


- (void)loadAttachments {
    
    NSItemProvider *provider;
    for (NSExtensionItem *extensionItem in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in extensionItem.attachments) {
            provider = itemProvider;
        }
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_EXT_SHARE_PROCESS_TITLE", nil)];
    
    [[QMShareTasks loadItemsForItemProvider:provider] continueWithExecutor:BFExecutor.mainThreadExecutor
                                                               withBlock:^id _Nullable(BFTask<QMItemProviderResult *> * _Nonnull t)
     {
         [SVProgressHUD dismiss];
         
         if (t.error) {
             [self completeShare:t.error];
         }
         else {
             
             self.attachment = t.result.attachment;
             self.shareText = t.result.text;
             
             dispatch_async(dispatch_queue_create("ShareDataSourceQueue", DISPATCH_QUEUE_CONCURRENT), ^{
                 NSArray *dialogsToShare = [self dialogsForDataSource];
                 NSArray *contactsToShare = [self contactsForDataSource];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     self.shareTableViewController =
                     [QMShareTableViewController qm_shareTableViewControllerWithDialogs:dialogsToShare
                                                                               contacts:contactsToShare];
                     
                     UINavigationController *navigationController =
                     [[UINavigationController alloc] initWithRootViewController:self.shareTableViewController];
                     
                     navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                     
                     [SVProgressHUD setViewForExtension:navigationController.view];
                     
                     [self presentViewController:navigationController
                                        animated:YES
                                      completion:nil];
                     
                     self.shareTableViewController.shareControllerDelegate = self;
                 });
             });
         }
         
         [SVProgressHUD dismiss];
         
         return nil;
     }];
}

- (void)completeShare:(nullable NSError *)error {
    __weak typeof(self) weakSelf = self;
    
    [self.shareTableViewController
     dismissLoadingAlertControllerAnimated:NO
     withCompletion:^{
         
         error ?
         [SVProgressHUD showErrorWithStatus:error.localizedDescription] :
         [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"QM_EXT_SHARE_SUCESS_MESSAGE", nil)];
         
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDismissTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             __strong typeof(weakSelf) strongSelf = weakSelf;
             [strongSelf dismiss];
         });
     }];
}


- (void)dismiss {
    
    if (self.extensionContext) {
        [self.extensionContext completeRequestReturningItems:nil
                                           completionHandler:nil];
    }
}

- (void)configureReachability {
    
    _internetConnection = [Reachability reachabilityForInternetConnection];
    
    // setting unreachable block
    [_internetConnection setUnreachableBlock:^(Reachability __unused *reachability) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // reachability block could possibly be called in background thread
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_LOST_INTERNET_CONNECTION", nil)
                                      maskType:SVProgressHUDMaskTypeNone];
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
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_LOST_INTERNET_CONNECTION", nil)
                                  maskType:SVProgressHUDMaskTypeNone];
        return;
    }
    
    [self.shareTableViewController
     showLoadingAlertControllerWithStatus:NSLocalizedString(@"QM_EXT_SHARE_SHARING_TITLE", nil)
     animated:YES
     withCompletion:nil];
    
    __weak typeof(self) weakSelf = self;
    self.shareOperation =
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
                  
                  [SVProgressHUD showErrorWithStatus:errorText];
              }
              else if (completed) {
                  [strongSelf completeShare:nil];
              }
          }];
         
     }];
    
    self.shareOperation.operationDelegate = self;
    [self.shareOperation start];
}

- (void)didCancelSharing {
    
    [self.shareTableViewController dismissLoadingAlertControllerAnimated:YES
                                                          withCompletion:nil];
    [self.shareOperation cancel];
}

- (void)didTapCancelBarButton {
    
    [self.extensionContext completeRequestReturningItems:nil
                                       completionHandler:nil];
}


//MARK: - QMShareEtxentionOperationDelegate

- (BFTask <NSString *> *)dialogIDForUser:(QBUUser *)user {
    return [QMShareTasks dialogIDForUser:user];
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

@end
