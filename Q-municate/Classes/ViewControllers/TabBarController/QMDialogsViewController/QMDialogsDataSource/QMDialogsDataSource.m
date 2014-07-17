//
//  QMDialogsDataSource.m
//  Qmunicate
//
//  Created by Andrey on 13.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDialogsDataSource.h"
#import "QMDialogCell.h"
#import "SVProgressHUD.h"
#import "QMApi.h"

@interface QMDialogsDataSource() <UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic, readonly) NSMutableArray *dialogs;

@end

@implementation QMDialogsDataSource

- (instancetype)initWithTableView:(UITableView *)tableView {
    
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        self.tableView.dataSource = self;
        
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

- (NSMutableArray *)dialogs {
    
    return [[QMApi instance] dialogs];
}

NSString *const kQMDialogCellID = @"QMDialogCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMDialogCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMDialogCellID];
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    cell.dialog = dialog;
    
    return cell;
}

@end
