//
//  QMShareDialogsTableViewController.m
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/4/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMShareDialogsTableViewController.h"
#import <Quickblox/Quickblox.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "QMShareTableViewCell.h"
#import "QMExtensionCache.h"
#import "QMColors.h"
#import <UIKit/UIKit.h>
#import "QMShareDataSource.h"
#import "QMShareItemsDataProvider.h"
#import "QMSearchResultsController.h"
#import "QMNoResultsCell.h"
#import "QMImages.h"
#import "QMShareContactsTableViewCell.h"
#import "QBChatDialog+QMShareItemProtocol.h"
#import "NSURL+QMShareExtension.h"
#import "QMShareTasks.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "QMLog.h"
#import <Quickblox/QBDarwinNotificationCenter.h>
#import <QMServicesDevelopment/QMServices.h>

//SVProgressHUD for extension
#define SV_APP_EXTENSIONS 1

#define DEVELOPMENT 1

#if DEVELOPMENT == 0

// Production
static const NSUInteger kQMApplicationID = 13318;
static NSString * const kQMAuthorizationKey = @"WzrAY7vrGmbgFfP";
static NSString * const kQMAuthorizationSecret = @"xS2uerEveGHmEun";
static NSString * const kQMAccountKey = @"6Qyiz3pZfNsex1Enqnp7";

#else

// Development
static const NSUInteger kQMApplicationID = 36125;
static NSString * const kQMAuthorizationKey = @"gOGVNO4L9cBwkPE";
static NSString * const kQMAuthorizationSecret = @"JdqsMHCjHVYkVxV";
static NSString * const kQMAccountKey = @"6Qyiz3pZfNsex1Enqnp7";

#endif

static NSString * const kQMAppGroupIdentifier = @"group.com.quickblox.qmunicate";

@interface QMShareDialogsTableViewController () <
QMSearchDataProviderDelegate,
QMSearchResultsControllerDelegate,
UISearchControllerDelegate,
UISearchResultsUpdating,
UISearchBarDelegate>

@property (strong, nonatomic) QMShareDataSource *tableViewDataSource;
@property (strong, nonatomic) QMShareSearchControllerDataSource *searchDataSource;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) QMSearchResultsController *searchResultsController;
@property (strong, nonatomic) BFCancellationTokenSource *cancellationTokenSource;
@property (weak, nonatomic) id observer;
@property (weak, nonatomic) BFTask *shareTask;

@end

@implementation QMShareDialogsTableViewController

- (void)configure {
    // Quickblox settings
    [QBSettings setApplicationID:kQMApplicationID];
    [QBSettings setAuthKey:kQMAuthorizationKey];
    [QBSettings setAuthSecret:kQMAuthorizationSecret];
    [QBSettings setAccountKey:kQMAccountKey];
    [QBSettings setLogLevel:QBLogLevelNothing];
    [QBSettings setApplicationGroupIdentifier:kQMAppGroupIdentifier];
    
   self.observer = [[QBDarwinNotificationCenter defaultCenter] addObserverForName:kQBResetSessionNotification usingBlock:^{
       NSLog(@"RESET SESSION");
    }];
    QMLogSetEnabled(YES);
    QMLog(@"Configure extension");
    [[UISearchBar appearance] setBarTintColor:QMSecondaryApplicationColor()];
    [[UISearchBar appearance] setSearchBarStyle:UISearchBarStyleMinimal];
    
    [[UISearchBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setBackgroundImage:QMStatusBarBackgroundImage() forBarPosition:0 barMetrics:UIBarMetricsDefault];
    
    
    [[UITextField appearance] setTintColor:QMSecondaryApplicationColor()];
    [UITextField appearance].keyboardAppearance = UIKeyboardAppearanceDark;
    
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem.tintColor = QMSecondaryApplicationColor();
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Share"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(share)];
    self.navigationItem.rightBarButtonItem.tintColor = QMSecondaryApplicationColor();
    
    [SVProgressHUD setViewForExtension:self.navigationController.view];
    
    [self updateShareButton];
}

- (void)dismiss {
    [self completeShare:nil];
}

//MARK: - Helpers

- (BFTask <QBChatDialog *>*)createPrivateChatWithOpponentID:(NSUInteger)opponentID {
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypePrivate];
    chatDialog.occupantIDs = @[@(opponentID)];
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [QBRequest createDialog:chatDialog successBlock:^(QBResponse *__unused response, QBChatDialog *createdDialog) {
            [source setResult:createdDialog];
            
        } errorBlock:^(QBResponse *__unused response) {
            [source setError:response.error.error];
        }];
    });
}


- (BFTask <NSString *> *)dialogIDForUser:(QBUUser *)user {
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatDialog*_Nullable dialog, NSDictionary<NSString *,id> * _Nullable __unused bindings) {
        return dialog.type == QBChatDialogTypePrivate && [dialog.occupantIDs containsObject:@(user.ID)];
    }];
    
    QBChatDialog *dialog = [[self.dialogsToShare filteredArrayUsingPredicate:predicate] firstObject];
    
    if (dialog) {
        return [BFTask taskWithResult:dialog.ID];
    }
    else {
        return [[self createPrivateChatWithOpponentID:user.ID] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull t) {
            if (t.error) {
                return [BFTask taskWithError:t.error];
            }
            else {
                return [BFTask taskWithResult:t.result.ID];
            }
        }];
    }
}

- (BFTask <NSString *>*)dialogIDForShareItem:(id <QMShareItemProtocol>)shareItem {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        if ([shareItem isKindOfClass:QBChatDialog.class]) {
            [source setResult:((QBChatDialog *)shareItem).ID];
        }
        else {
            [[self dialogIDForUser:(QBUUser *)shareItem] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull t) {
                t.error ? [source setError:t.error] : [source setResult:t.result];
                return nil;
            }];
        }
    });
}

- (BFTask *)shareTaskWithMessage:(QBChatMessage *)message
                       shareItem:(id<QMShareItemProtocol>)shareItem {
    
    return [[self dialogIDForShareItem:shareItem] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull dialogTask) {
        NSLog(@"dialogTask = %@", dialogTask);
        NSString *dialogID = dialogTask.result;
        if (self.cancellationTokenSource.cancellationRequested) {
            NSLog(@"Cancelled");
            return [BFTask cancelledTask];
        }
        
        NSUInteger senderID = QBSession.currentSession.currentUser.ID;
        message.senderID = senderID;
        message.markable = YES;
        message.deliveredIDs = @[@(senderID)];
        message.readIDs = @[@(senderID)];
        message.dialogID = dialogID;
        message.dateSent = [NSDate date];
        
        return [[self sendMessage:message] continueWithBlock:^id _Nullable(BFTask * _Nonnull sendMessageTask)  {
            NSLog(@"sendMessageTask = %@", sendMessageTask);
            if (sendMessageTask.error) {
                return [BFTask taskWithError:sendMessageTask.error];
            }
            
            return [BFTask taskWithResult:nil];
            
        } cancellationToken:self.cancellationTokenSource.token];
    }];
}



- (void)share {
    
    [self updateShareButton];
    
    if (self.shareTask) {
        return;
    }

    __weak typeof(self) weakSelf = self;
    
    [self showActivityAlertControllerWithStatus:@"Sharing..." cancelAction:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf cancelSharing];
    }];
    
    NSItemProvider *provider;
    for (NSExtensionItem *extensionItem in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in extensionItem.attachments) {
            provider = itemProvider;
        }
    }
    
   
    

    self.cancellationTokenSource = [[BFCancellationTokenSource alloc] init];
    
    [self.cancellationTokenSource.token registerCancellationObserverWithBlock:^{
        [SVProgressHUD showSuccessWithStatus:@"Cancelled"];
        
    }];
    
 self.shareTask = [[QMShareTasks messageForItemProvider:provider] continueWithBlock:^id _Nullable(BFTask<QBChatMessage *> * _Nonnull messageTask) {
     
        if (messageTask.result) {
            
            NSSet *itemsToShare = self.tableViewDataSource.selectedItems.copy;
            NSMutableArray *tasks = [NSMutableArray arrayWithCapacity:itemsToShare.count];
            
            for (id <QMShareItemProtocol> shareItem in itemsToShare) {
                QBChatMessage *message =  [QBChatMessage new];
                message.text = messageTask.result.text;
                message.attachments = messageTask.result.attachments;
                [tasks addObject:[self shareTaskWithMessage:message shareItem:shareItem]];
            }
            
            return  [[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused t) {
                
                if (t.isCompleted) {
                    self.cancellationTokenSource = nil;
                    [SVProgressHUD showSuccessWithStatus:@"Completed"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self completeShare:nil];
                    });
                }

                return nil;
                
            } cancellationToken:self.cancellationTokenSource.token];
        }
        else if (messageTask.error) {
            [SVProgressHUD showErrorWithStatus:messageTask.error.localizedDescription];
        }
        return nil;
    }];
    
}

- (BFTask *)sendMessage:(QBChatMessage *)message {
    
    if (message.attachments > 0 && !message.isLocationMessage) {
        QBChatAttachment *attachment = message.attachments.firstObject;
        
        return [[self uploadAttachment:attachment] continueWithBlock:^id _Nullable(BFTask<QBChatAttachment *> * _Nonnull t) {
            
            message.attachments = @[t.result];
            return make_task(^(BFTaskCompletionSource * _Nonnull source) {
                [QBRequest sendMessage:message
                          successBlock:^(QBResponse * _Nonnull __unused response, QBChatMessage * _Nonnull __unused tMessage) {
                              [source setResult:tMessage];
                          }
                            errorBlock:^(QBResponse * _Nonnull response) {
                                [source setError:response.error.error];
                            }];
            });
        }];
    }
    else {
        return make_task(^(BFTaskCompletionSource * _Nonnull source) {
            [QBRequest sendMessage:message
                      successBlock:^(QBResponse * _Nonnull __unused response, QBChatMessage * _Nonnull __unused tMessage) {
                          [source setResult:tMessage];
                      }
                        errorBlock:^(QBResponse * _Nonnull response) {
                            [source setError:response.error.error];
                        }];
        });
    }
}

- (BFTask <QBChatAttachment *>*)uploadAttachment:(QBChatAttachment *)attatchment {
    
    NSData *dataToSend = ^NSData *{
        
        if (attatchment.attachmentType == QMAttachmentContentTypeImage) {
            return imageData(attatchment.image);
        }
        
        return nil;
        
    }();
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        if (dataToSend) {
            [QBRequest TUploadFile:dataToSend
                          fileName:attatchment.name
                       contentType:attatchment.contentType
                          isPublic:NO
                      successBlock:^(QBResponse * __unused  _Nonnull response,
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
        else if (attatchment.localFileURL) {
            [QBRequest uploadFileWithUrl:attatchment.localFileURL
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
    });
}

- (void)updateShareButton {
    
    self.navigationItem.rightBarButtonItem.enabled =
    self.tableViewDataSource.selectedItems.count > 0 && !self.shareTask;
}

- (void)configureSearch {
    
    self.searchResultsController = [[QMSearchResultsController alloc] init];
    self.searchResultsController.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchBar.placeholder = @"Search";
    self.searchController.searchBar.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    [self.searchController.searchBar sizeToFit]; // iOS8 searchbar sizing
    
    [QMNoResultsCell registerForReuseInTableView:self.searchResultsController.tableView];
    [QMShareTableViewCell registerForReuseInView:self.searchResultsController.tableView];
    [QMShareContactsTableViewCell registerForReuseInTableView:self.searchResultsController.tableView];
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = self.searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    }
    else {
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
#else
    self.tableView.tableHeaderView = self.searchController.searchBar;
#endif
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
}



- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (NSArray *)contactsToShare {
    
    if (!_contactsToShare) {
        
        NSMutableArray *userIDs = [NSMutableArray array];
        NSArray *allContactListItems = QMExtensionCache.contactsCache.allContactListItems;
        
        for (QBContactListItem *item in allContactListItems) {
            if (item.subscriptionState != QBPresenceSubscriptionStateNone) {
                [userIDs addObject:@(item.userID)];
            }
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.ID IN %@",userIDs];
        
        _contactsToShare = [QMExtensionCache.usersCache.allUsers filteredArrayUsingPredicate:predicate];
    }
    
    return _contactsToShare;
}


- (NSArray *)dialogsToShare {
    
    if (!_dialogsToShare) {
        _dialogsToShare = QMExtensionCache.chatCache.allDialogs;
    }
    
    return _dialogsToShare;
}


- (void)configureDataSource {
    
    NSMutableArray *dialogsDataSource = [NSMutableArray array];
    
    NSPredicate *privateDialogsPredicate = [NSPredicate predicateWithFormat:@"SELF.type == %@", @(QBChatDialogTypePrivate)];
    NSArray *privateDialogs = [self.dialogsToShare filteredArrayUsingPredicate:privateDialogsPredicate];
    
    for (QBChatDialog *dialog in privateDialogs) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.ID == %@",@(dialog.recipientID)];
        QBUUser *recipient = [self.contactsToShare filteredArrayUsingPredicate:predicate].firstObject;
        if (recipient) {
            dialog.recipient = recipient;
            [dialogsDataSource addObject:recipient];
        }
    }
    
    NSPredicate *groupDialogsPredicate = [NSPredicate predicateWithFormat:@"SELF.type == %@ AND SELF.name.length > 0", @(QBChatDialogTypeGroup)];
    
    NSArray *groupDialogs = [self.dialogsToShare filteredArrayUsingPredicate:groupDialogsPredicate];
    [dialogsDataSource addObjectsFromArray:groupDialogs];
    
    NSArray *sortedByDateDialogs = [dialogsDataSource sortedArrayUsingComparator:^NSComparisonResult(id <QMShareItemProtocol> _Nonnull obj1, id  <QMShareItemProtocol>_Nonnull obj2) {
        return [obj2.updateDate compare:obj1.updateDate];
    }];
    
    //Main data source
    self.tableViewDataSource = [[QMShareDataSource alloc] initWithShareItems:sortedByDateDialogs
                                                      alphabetizedDataSource:NO];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updateDate"
                                                                   ascending:NO];;
    self.tableViewDataSource.sortDescriptors = @[sortDescriptor];
    self.tableView.dataSource = self.tableViewDataSource;
    
    //Search data source
    self.searchDataSource = ({
        
        QMShareSearchControllerDataSource *searchDataSource = [[QMShareSearchControllerDataSource alloc] initWithShareItems:groupDialogs
                                                                                                     alphabetizedDataSource:YES];
        
        QMShareItemsDataProvider *itemsSearchProvider = [[QMShareItemsDataProvider alloc] initWithShareItems:groupDialogs];
        itemsSearchProvider.delegate = self.searchResultsController;
        searchDataSource.searchDataProvider = itemsSearchProvider;
        
        searchDataSource;
    });
    
    //Contacts data source
    self.searchDataSource.contactsDataSource = ({
        
        NSArray *sortedByDateContacts = [self.contactsToShare sortedArrayUsingComparator:^NSComparisonResult(id <QMShareItemProtocol> _Nonnull obj1, id  <QMShareItemProtocol>_Nonnull obj2) {
            return [obj2.updateDate compare:obj1.updateDate];
        }];
        
        QMShareItemsDataProvider *contactsProvider = [[QMShareItemsDataProvider alloc] initWithShareItems:sortedByDateContacts];
        contactsProvider.delegate = self;
        
        QMShareDataSource *contactsDataSource = [[QMShareDataSource alloc] initWithShareItems:(NSArray <id <QMShareItemProtocol>> *)sortedByDateContacts
                                                                       alphabetizedDataSource:NO];
        contactsDataSource.searchDataProvider = contactsProvider;
        
        contactsDataSource;
    });
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configure];
    
    [self configureSearch];
    
    [QMShareTableViewCell registerForReuseInView:self.tableView];
    [QMNoResultsCell registerForReuseInTableView:self.tableView];

    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (!QBSession.currentSession.currentUser.ID) {
        
        [SVProgressHUD showErrorWithStatus:@"You should be logged in to Q-Municate"
                                  maskType:SVProgressHUDMaskTypeBlack];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self completeShare:nil];
        });
        
        return;
    }
    
    [self configureDataSource];
    [self updateDataSource];
}

- (void)updateDataSource {
    

}

//MARK: - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)__unused
tableView heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    return [QMShareTableViewCell height];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id <QMShareViewProtocol> view = [tableView cellForRowAtIndexPath:indexPath];
    id <QMShareItemProtocol> item = [self.tableViewDataSource objectAtIndexPath:indexPath];
    
    [self.tableViewDataSource selectItem:item
                                 forView:view];
    
    [self updateShareButton];
}

- (void)cancelSharing {
    
    if (self.cancellationTokenSource) {
        NSLog(@"cancellationTokenSource cancel");
        [self.cancellationTokenSource cancel];
    }
}
- (void)completeShare:(nullable NSError *)error {
    
    if (self.extensionContext) {
        [self hideExtensionControllerWithCompletion:^{
            
            if (error) {
                [self.extensionContext cancelRequestWithError:error];
            }
            else {
                [self.extensionContext completeRequestReturningItems:nil
                                                   completionHandler:nil];
            }
        }];
    }
    else {
        [self dismissViewControllerAnimated:YES
                                 completion:NULL];
    }
}


- (void)hideExtensionControllerWithCompletion:(dispatch_block_t)completion {
    [UIView animateWithDuration:0.2 animations:^{
        
        self.navigationController.view.transform =
        CGAffineTransformMakeTranslation(0, self.navigationController.view.frame.size.height);
        
        completion ? completion() : nil;
    }];
    
}

static inline NSData * __nullable imageData(UIImage * __nonnull image) {
    
    int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    
    if (hasAlpha) {
        return UIImagePNGRepresentation(image);
    }
    else {
        return UIImageJPEGRepresentation(image, 1.0f);
    }
}

//MARK: - UISearchControllerDelegate

- (void)willDismissSearchController:(UISearchController *)__unused searchController {
    
    [self.tableViewDataSource.selectedItems removeAllObjects];
    
    [self.tableViewDataSource.selectedItems addObjectsFromArray:^NSArray *{
        
        NSMutableSet *selectedItems = [NSMutableSet set];
        [selectedItems unionSet:self.searchDataSource.selectedItems];
        [selectedItems unionSet:self.searchDataSource.contactsDataSource.selectedItems];
        
        return selectedItems.allObjects;
    }()];
    
    [self updateShareButton];
    [self.tableView reloadData];
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    
    [self.searchDataSource.selectedItems removeAllObjects];
    [self.searchDataSource.selectedItems addObjectsFromArray:self.tableViewDataSource.selectedItems.allObjects];
    
    self.searchResultsController.tableView.dataSource = self.searchDataSource;
    
    searchController.searchResultsController.view.hidden = NO;
}

- (void)searchDataProvider:(QMSearchDataProvider *)__unused searchDataProvider
             didUpdateData:(NSArray *)__unused data {
    
}
- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)__unused searchDataProvider {
    
    if (self.searchDataSource.showContactsSection) {
        QMShareContactsTableViewCell *contactsCell = [self.searchResultsController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                                                                      inSection:0]];
        contactsCell ? [contactsCell.contactsCollectionView reloadData] : nil;
    }
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    searchController.searchResultsController.view.hidden = NO;
}

//MARK: - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    searchController.searchResultsController.view.hidden = NO;
    [self.searchDataSource performSearch:searchController.searchBar.text];
}

//MARK: - QMSearchResultsControllerDelegate

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController
         willBeginScrollResults:(UIScrollView *)__unused scrollView {
    
    [self.searchController.searchBar endEditing:YES];
}

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController
                didSelectObject:(id)object {
    
    NSIndexPath *indexPath = [self.searchDataSource indexPathForObject:object];
    UITableViewCell *cell = [self.searchResultsController.tableView cellForRowAtIndexPath:indexPath];
    
    [self.searchDataSource selectItem:object
                              forView:(id <QMShareViewProtocol>)cell];
    
    [self.tableViewDataSource selectItem:object
                                 forView:[self.tableView cellForRowAtIndexPath:[self.tableViewDataSource indexPathForObject:object]]];
    [self updateShareButton];
}


- (void)showActivityAlertControllerWithStatus:(NSString *)status
                                 cancelAction:(dispatch_block_t)cancelAction {
    
    NSString *message = [NSString stringWithFormat:@"%@\n",status];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action)
                                {
                                    cancelAction ? cancelAction() : nil;
                                }]];
    
    
    UIActivityIndicatorView *indicator =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setUserInteractionEnabled:NO];
    [indicator startAnimating];
    indicator.color = QMSecondaryApplicationColor();
    
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [alertController.view addSubview:indicator];
    
    NSDictionary *views = @{@"alertController" : alertController.view,
                            @"indicator" : indicator};
    
    NSArray *constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicator]-(45)-|" options:0 metrics:nil views:views];
    NSArray *constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
    NSArray *constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
    
    [alertController.view addConstraints:constraints];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

@end
