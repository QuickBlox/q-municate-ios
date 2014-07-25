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
#import "QMChatReceiver.h"

@interface QMDialogsDataSource()

<UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic, readonly) NSMutableArray *dialogs;

@end

@implementation QMDialogsDataSource

- (instancetype)initWithTableView:(UITableView *)tableView {
    
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        self.tableView.dataSource = self;
        
        [[QMChatReceiver instance] chatRoomDidReceiveMessageWithTarget:self block:^(QBChatMessage *message, NSString *roomJID) {
            
            QBChatDialog *chatDialog = [[QMApi instance] chatDialogWithID:roomJID];
            NSLog(@"chatRoomDidReceiveMessageWithTarget");
        }];

        __weak __typeof(self)weakSelf = self;
        
        [[QMChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {

            QBChatDialog *dialog = [[QMApi instance] chatDialogWithID:message.cParamDialogID];
            if (dialog) {                
                NSUInteger idx = [self.dialogs indexOfObject:dialog];
                [weakSelf reloadRowAtIndex:idx];
            }
            
        }];
        
        [[QMChatReceiver instance] chatRoomDidCreateWithTarget:self block:^(NSString *roomName) {
            NSLog(@"chatRoomDidCreateWithTarget");
        }];
        
    }
    return self;
}

- (void)reloadRowAtIndex:(NSUInteger)index {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - UITableViewDataSource

- (void)fetchDialog:(void(^)(void))comletion {
    [[QMApi instance] fetchAllDialogs:comletion];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dialogs.count;
}

- (QBChatDialog *)dialogAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    return dialog;
}

- (NSArray *)dialogs {
    
    return [[QMApi instance] dialogHistory];
}

NSString *const kQMDialogCellID = @"QMDialogCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMDialogCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMDialogCellID];
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    cell.dialog = dialog;
    
    return cell;
}

@end
