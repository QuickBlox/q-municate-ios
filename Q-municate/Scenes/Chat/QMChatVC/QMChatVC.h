//
//  QMChatVC.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/9/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatViewController.h"

@interface QMChatVC : QMChatViewController

@property (strong, nonatomic) QBChatDialog *chatDialog;

+ (QMChatVC *)chatViewControllerWithChatDialog:(QBChatDialog *)chatDialog;

- (instancetype)initWithChatDialog:(QBChatDialog *)chatDialog;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end
