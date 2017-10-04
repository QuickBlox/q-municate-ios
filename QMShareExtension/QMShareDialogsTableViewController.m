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

#import "QMSiriCache.h"

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

@interface QMShareDialogsTableViewController ()

@property (strong, nonatomic) QMSiriCache *siriCache;
@property (strong, nonatomic) NSMutableArray *dataSource;

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
    
    _siriCache = [[QMSiriCache alloc] initWithApplicationGroupIdentifier:kQMAppGroupIdentifier];
}

- (void)viewDidLoad {
    
    [self configure];
    
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    
    __weak typeof(self) weakSelf = self;
    
    [self.tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:kReusableCellIdentifier];
    
    [self.siriCache allGroupDialogsWithCompletionBlock:^(NSArray<QBChatDialog *> *results) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.dataSource = [NSMutableArray arrayWithArray:results];
        [strongSelf.tableView reloadData];
    }];
}

//MARK: - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatDialog *dialog = self.dataSource[indexPath.row];
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *provider in item.attachments) {
            
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
                    message.senderID = senderID;
                    message.markable = YES;
                    message.deliveredIDs = @[@(senderID)];
                    message.readIDs = @[@(senderID)];
                    message.dialogID = dialog.ID;
                    message.dateSent = [NSDate date];
                    
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
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReusableCellIdentifier
                                                            forIndexPath:indexPath];
    
    QBChatDialog *dialog = self.dataSource[indexPath.row];
    cell.textLabel.text = dialog.name;
    
    return cell;
}


- (void)completeShare:(nullable NSError *)error {
    
    if (error) {
        [self.extensionContext cancelRequestWithError:error];
    }
    else {
        [self.extensionContext completeRequestReturningItems:nil
                                           completionHandler:nil];
    }
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

@end
