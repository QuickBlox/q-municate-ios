//
//  QMChatInputView.m
//  Q-municate
//
//  Created by Andrey on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatInputView.h"

@interface QMChatInputView()

@property (assign, nonatomic) CGFloat textInitialHeight;
@property (assign, nonatomic) CGFloat textMaxHeight;
@property (weak, nonatomic) id <QMChatInputDelegate> delegate;
@property (weak, nonatomic) UITableView *tableView;

@end

@implementation QMChatInputView

- (instancetype)initWithTableView:(UITableView *)tableView delegate:(id <QMChatInputDelegate>)delegate {
    
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        self.tableView = tableView;
        [self defaultData];
    }
    
    return self;
}

- (void)defaultData {
    
    self.translucent = YES;
    self.textInitialHeight = 40;
    self.textMaxHeight = 100;
    
    CGRect frame  = CGRectMake(0,
                               0,
                               [UIScreen mainScreen].bounds.size.width,
                               self.superview.bounds.size.height - self.textInitialHeight);
    self.frame = frame;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top,
                                                  0.0,
                                                  self.frame.size.height,
                                                  0.0);
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

@end
