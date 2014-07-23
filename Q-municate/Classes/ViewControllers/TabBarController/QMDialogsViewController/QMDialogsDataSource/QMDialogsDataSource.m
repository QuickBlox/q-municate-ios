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
        
        [[QMChatReceiver instance] chatDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
            
        }];
        
        [[QMChatReceiver instance] chatRoomDidCreateWithTarget:self block:^(NSString *roomName) {
            NSLog(@"chatRoomDidCreateWithTarget");
        }];
        
    }
    return self;
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
