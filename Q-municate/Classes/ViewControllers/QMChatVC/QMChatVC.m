//
//  QMChatVC.m
//  Q-municate
//
//  Created by Andrey on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatVC.h"
#import "QMChatInputView.h"
#import "QMChatCell.h"
#import "QMMessage.h"
#import "QMChatDataSource.h"

@interface QMChatVC ()

<UITableViewDelegate, QMChatInputDelegate>

@property (strong, nonatomic) QMChatInputView *inputView;
@property (strong, nonatomic) UIView *tableViewHeaderView;

@end

@implementation QMChatVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTableView];
    
    self.inputView = [[QMChatInputView alloc] initWithTableView:self.tableView delegate:self];
    [self.view addSubview:self.inputView];
}

- (void)setupTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableViewHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        self.tableView.frame.size.width,
                                                                        10)];
    self.tableView.tableHeaderView = self.tableViewHeaderView;
    
    self.tableView.autoresizingMask =
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.tableView];
}

- (void)setDataSource:(QMChatDataSource *)dataSource {
    
    _dataSource = dataSource;
}

@end
