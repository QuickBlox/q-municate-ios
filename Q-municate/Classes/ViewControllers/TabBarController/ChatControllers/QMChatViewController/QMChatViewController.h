//
//  QMChatViewController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMChatVC.h"

@interface QMChatViewController : QMChatVC

- (void)refreshMessagesShowingProgress:(BOOL)showingProgress;

@property (nonatomic, strong) QBChatDialog* dialog;
@property (nonatomic, assign) BOOL shouldUpdateNavigationStack;

@end
