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

NSString *const kQMChatCellID = @"ChatCell";

@interface QMChatVC ()

<UITableViewDataSource, UITableViewDelegate, QMChatInputDelegate>

@property (strong, nonatomic) QMChatInputView *inputView;
@property (strong, nonatomic) UIView *tableViewHeaderView;
@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation QMChatVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTableView];
    
    self.inputView = [[QMChatInputView alloc] initWithTableView:self.tableView delegate:self];
    [self.view addSubview:self.inputView];
    
    self.messages = [NSMutableArray array];

    QMMessage *message = [[QMMessage alloc] init];
    message.fromMe = YES;
    message.layout = QMChatCellLayoutConfigBubble;
    
    QBChatHistoryMessage *qbObj  = [[QBChatHistoryMessage alloc] init];
    qbObj.text =  @")";
    message.data = qbObj;
    [self.messages addObject:message];
    
    QMMessage *message1 = [[QMMessage alloc] init];
    message1.fromMe = NO;
    message1.layout = QMChatCellLayoutConfigBubble;
    
    QBChatHistoryMessage *qbObj1  = [[QBChatHistoryMessage alloc] init];
    qbObj1.text =  @"By in no ecstatic wondered disposal my speaking.";
    
    message1.data = qbObj1;
    [self.messages addObject:message1];
    
    QMMessage *message2 = [[QMMessage alloc] init];
    message2.fromMe = YES;
    message2.layout = QMChatCellLayoutConfigBubble;
    
    QBChatHistoryMessage *qbObj2  = [[QBChatHistoryMessage alloc] init];
    qbObj2.text =  @"By in no ecstatic wondered disposal my speaking. Direct wholly valley or uneasy it at really.By in no ecstatic wondered disposal my speaking. Direct wholly valley or uneasy it at really.";
    message2.data = qbObj2;
    [self.messages addObject:message2];
    
    QMMessage *message3 = [[QMMessage alloc] init];
    message3.fromMe = YES;
    message3.layout = QMChatCellLayoutConfigBubble;
    
    QBChatHistoryMessage *qbObj3  = [[QBChatHistoryMessage alloc] init];
    qbObj3.text =  @"By in no ecstatic wondered disposal my speaking. Direct wholly valley or uneasy it at really.By in no ecstatic wondered disposal my speaking. Direct wholly valley or uneasy it at really.By in no ecstatic wondered disposal my speaking. Direct wholly valley or uneasy it at really.";
    message3.data = qbObj3;
    [self.messages addObject:message];
    [self.messages addObject:message2];
    [self.messages addObject:message];
    [self.messages addObject:message2];
    [self.messages addObject:message2];
    [self.messages addObject:message1];
    [self.messages addObject:message3];
    
}

- (void)setupTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.tableView registerClass:QMChatCell.class forCellReuseIdentifier:kQMChatCellID];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMMessage *message = self.messages[indexPath.row];
    
    return message.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMChatCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMChatCellID forIndexPath:indexPath];
    cell.message = self.messages[indexPath.row];
    
    return cell;
}

@end
