//
//  QMDialogsDataSource.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 13.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDialogsDataSource.h"
#import "QMDialogCell.h"
#import "SVProgressHUD.h"
#import "QMApi.h"

@interface QMDialogsDataSource()
<
UITableViewDataSource,
QMChatServiceDelegate,
QMChatConnectionDelegate,
QMContactListServiceDelegate
>


@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic, readonly) NSMutableArray *dialogs;
@property (assign, nonatomic) NSUInteger unreadDialogsCount;

@end

@implementation QMDialogsDataSource

- (instancetype)initWithTableView:(UITableView *)tableView {
    
    self = [super init];
    if (self) {
        [[QMApi instance].chatService addDelegate:self];
        [[QMApi instance].contactListService addDelegate:self];
        self.tableView = tableView;
        self.tableView.dataSource = self;
    }
    
    return self;
}

- (void)retrieveUserIfNeededWithMessage:(QBChatMessage *)message
{
    __weak typeof(self)weakSelf = self;
    if (message.messageType == QMMessageTypeContactRequest) {
        [[QMApi instance] retriveIfNeededUserWithID:message.senderID completion:^(BOOL retrieveWasNeeded) {
            if (retrieveWasNeeded) {
                [weakSelf updateGUI];
            }
        }];
    }
}

- (void)updateGUI {
    
    [self.tableView reloadData];
    [self fetchUnreadDialogsCount];
}

- (void)setUnreadDialogsCount:(NSUInteger)unreadDialogsCount {
    
    if (_unreadDialogsCount != unreadDialogsCount) {
        _unreadDialogsCount = unreadDialogsCount;
        
        [self.delegate didChangeUnreadDialogCount:_unreadDialogsCount];
    }
}

- (void)fetchUnreadDialogsCount {
    
    NSArray * dialogs = [[QMApi instance] dialogHistory];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unreadMessagesCount > 0"];
    NSArray *result = [dialogs filteredArrayUsingPredicate:predicate];
    self.unreadDialogsCount = result.count;
}

- (void)insertRowAtIndex:(NSUInteger)index {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}

#pragma mark - UITableViewDataSource

- (void)fetchDialog:(void(^)(void))comletion {
    
    [[QMApi instance] fetchAllDialogs:comletion];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger count = self.dialogs.count;
    return count > 0 ? count:1;
}

- (QBChatDialog *)dialogAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *dialogs = self.dialogs;
    if (dialogs.count == 0) {
        return nil;
    }
    
    QBChatDialog *dialog = dialogs[indexPath.row];
    return dialog;
}

- (NSMutableArray *)dialogs {
    
    NSMutableArray *dialogs = [[QMApi instance].chatService.dialogsMemoryStorage dialogsSortByLastMessageDateWithAscending:NO].mutableCopy;
    
    return dialogs;
}

NSString *const kQMDialogCellID = @"QMDialogCell";
NSString *const kQMDontHaveAnyChatsCellID = @"QMDontHaveAnyChatsCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *dialogs = self.dialogs;
    
    if (dialogs.count == 0) {
        QMDialogCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMDontHaveAnyChatsCellID];
        return cell;
    }
    
    QMDialogCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMDialogCellID];
    QBChatDialog *dialog = dialogs[indexPath.row];
    cell.dialog = dialog;
    
    return cell;
}

#pragma mark - UITableViewDataSource Editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
#if DELETING_DIALOGS_ENABLED
    return YES;
#else
    return NO;
#endif
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        __weak typeof(self)weakSelf = self;
        
        [SVProgressHUD show];
        QBChatDialog *dialog = [self dialogAtIndexPath:indexPath];
        [[QMApi instance] deleteChatDialog:dialog completion:^(BOOL success) {
            
            [SVProgressHUD dismiss];
            (weakSelf.dialogs.count == 0) ?
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade] :
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        }];
    }
}

#pragma mark -
#pragma mark Chat Service Delegate

- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs {
    [self updateGUI];
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
    [[QMApi instance] fetchAllDialogs:^{
        [[QMApi instance] joinGroupDialogs];
    }];
    
    [self updateGUI];
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    [self updateGUI];
}

- (void)chatService:(QMChatService *)chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
    
    [self updateGUI];
    [self retrieveUserIfNeededWithMessage:message];
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    [self updateGUI];
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID {
    [self updateGUI];
}

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
    [self updateGUI];
}

#pragma mark Contact List Serice Delegate

- (void)contactListService:(QMContactListService *)contactListService didAddUsers:(NSArray *)users {
    [self.tableView reloadData];
}

#pragma mark Chat Connection Delegate

- (void)chatServiceChatDidLogin {
    [[QMApi instance] fetchAllDialogs:^{
        [[QMApi instance] joinGroupDialogs];
    }];
}

@end
