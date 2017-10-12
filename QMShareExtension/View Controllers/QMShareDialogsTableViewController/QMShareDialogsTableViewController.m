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
#import "QMServicesManager.h"
#import "QMShareTableViewCell.h"
#import "QMExtensionCache.h"
#import "QMColors.h"
#import <UIKit/UIKit.h>
#import "QMAlphabetizer.h"
#import "QMShareDataSource.h"
#import "QMShareItemsDataProvider.h"
#import "QMSearchResultsController.h"
#import "QMNoResultsCell.h"

static NSString * const kReusableCellIdentifier = @"kReusableCellIdentifier";

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
QMSearchResultsControllerDelegate,
UISearchControllerDelegate,
UISearchResultsUpdating,
UISearchBarDelegate>

@property (strong, nonatomic) QMShareDataSource *tableViewDataSource;
@property (strong, nonatomic) QMShareDataSource *searchDataSource;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) QMSearchResultsController *searchResultsController;

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
    
    
    self.navigationController.navigationBar.titleTextAttributes =
    @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    self.navigationController.navigationBar.barTintColor = QMMainApplicationColor();
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(dismiss)];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Share"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(share)];
    
    [self updateSendButton];
}

- (void)dismiss {
    [self completeShare:nil];
}

- (void)share {
    [self completeShare:nil];
}

- (void)updateSendButton {
    
    self.navigationItem.rightBarButtonItem.enabled = self.tableViewDataSource.selectedItems.count > 0;
}

- (void)configureSearch {
    
    self.searchResultsController = [[QMSearchResultsController alloc] init];
    self.searchResultsController.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"QM_STR_SEARCH_BAR_PLACEHOLDER", nil);
    self.searchController.searchBar.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    [self.searchController.searchBar sizeToFit]; // iOS8 searchbar sizing
    
    [QMNoResultsCell registerForReuseInTableView:self.searchResultsController.tableView];
    [QMShareTableViewCell registerForReuseInView:self.searchResultsController.tableView];
    
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
    
    self.definesPresentationContext = YES;
}

- (void)viewDidLoad {
    
    [self configure];
    [self configureSearch];
    [super viewDidLoad];
    
    [QMShareTableViewCell registerForReuseInView:self.tableView];
    [QMNoResultsCell registerForReuseInTableView:self.tableView];
    
    [self get];
    self.tableView.tableFooterView = [UIView new];
    
    NSArray *dialogs = QMExtensionCache.chatCache.allDialogs;
    
    QMShareItemsDataProvider *itemsSearchProvider = [[QMShareItemsDataProvider alloc] initWithShareItems:dialogs];
    itemsSearchProvider.delegate = self.searchResultsController;
    
    self.tableViewDataSource = [[QMShareDataSource alloc] initWithShareItems:dialogs
                                                      alphabetizedDataSource:YES];
    
    self.tableView.dataSource = self.tableViewDataSource;
    
    self.searchDataSource = [[QMShareDataSource alloc] initWithShareItems:dialogs
                                                   alphabetizedDataSource:YES];
    self.searchDataSource.searchDataProvider = itemsSearchProvider;
    itemsSearchProvider.dataSource = self.searchDataSource;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [QMShareTableViewCell height];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id <QMShareViewProtocol> view = [tableView cellForRowAtIndexPath:indexPath];
    
    [self.tableViewDataSource selectItemAtIndexPath:indexPath
                                            forView:view];
    [self updateSendButton];
}

- (void)completeShare:(nullable NSError *)error {
    
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

- (void)sendMessage:(QBChatMessage *)message
               data:(NSData *)data {
    
    UIImage *image = [UIImage imageWithData:data];
    QBChatAttachment *imageAttachment = [QBChatAttachment imageAttachmentWithImage:image];
    
    [QBRequest TUploadFile:data
                  fileName:imageAttachment.name
               contentType:imageAttachment.contentType
                  isPublic:YES
              successBlock:^(QBResponse * _Nonnull response, QBCBlob * _Nonnull tBlob) {
                  imageAttachment.ID = tBlob.UID;
                  message.attachments = @[imageAttachment];
                  [QBRequest sendMessage:message successBlock:^(QBResponse * _Nonnull response, QBChatMessage * _Nonnull tMessage) {
                      [self completeShare:nil];
                  } errorBlock:^(QBResponse * _Nonnull response) {
                      [self completeShare:response.error.error];
                  }];
                  
              } statusBlock:nil
                errorBlock:^(QBResponse * _Nonnull response) {
                    [self completeShare:response.error.error];
                }];
}


- (void)hideExtensionControllerWithCompletion:(dispatch_block_t)completion {
    [UIView animateWithDuration:0.2 animations:^{
        self.navigationController.view.transform = CGAffineTransformMakeTranslation(0, self.navigationController.view.frame.size.height);
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

- (void)get {
    
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        
        for (NSItemProvider *provider in item.attachments) {
            
            if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeAudio]) {
                NSLog(@"kUTTypeAudio");
            }
            
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie]) {
                NSLog(@"kUTTypeMovie");
            }
            
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeGIF]) {
                NSLog(@"kUTTypeGIF");
            }
            
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                NSLog(@"kUTTypeImage");
            }
            
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL]) {
                NSLog(@"kUTTypeFileURL");
            }
            
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]) {
                NSLog(@"kUTTypeText");
            }
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                NSLog(@"kUTTypeURL");
            }
            
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeData]) {
                NSLog(@"kUTTypeData");
                
            }
        }}
    /*
     
     [provider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
     
     NSData *dataToSend = nil;
     
     if ([(id)item isKindOfClass:NSURL.class]) {
     
     dataToSend = [NSData dataWithContentsOfURL:(NSURL *)item];
     NSLog(@"Item is URL = %@", item);
     }
     else if ([(id)item isKindOfClass:UIImage.class]) {
     NSLog(@"Item is image = %@", item);
     dataToSend = imageData((UIImage*)item);
     }
     
     if (dataToSend) {
     
     NSUInteger senderID = QBSession.currentSession.currentUser.ID;
     QBChatMessage *message = [QBChatMessage message];
     //                    message.senderID = senderID;
     //                    message.markable = YES;
     //                    message.deliveredIDs = @[@(senderID)];
     //                    message.readIDs = @[@(senderID)];
     //                    message.dialogID = dialog.ID;
     //                    message.dateSent = [NSDate date];
     
     [self sendMessage:message
     data:dataToSend];
     
     }
     else {
     NSError *error =
     [NSError errorWithDomain:@""
     code:0
     userInfo:@{NSLocalizedDescriptionKey : @"Not supported share data"}];
     
     [self completeShare:error];
     }
     }];
     }
     }*/
}

//MARK: - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)__unused searchController {
    
    [self.searchDataSource.selectedItems addObjectsFromArray:self.tableViewDataSource.selectedItems.allObjects];
    self.searchResultsController.tableView.dataSource = self.searchDataSource;
}

//MARK: - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    [self.searchDataSource.searchDataProvider performSearch:searchController.searchBar.text];
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
    
    [self.searchDataSource selectItemAtIndexPath:indexPath
                                         forView:(id <QMShareViewProtocol>)cell];
    
    [self.tableViewDataSource selectItemAtIndexPath:[self.tableViewDataSource indexPathForObject:object]
                                            forView:[self.tableView cellForRowAtIndexPath:[self.tableViewDataSource indexPathForObject:object]]];
    [self updateSendButton];
}

@end
