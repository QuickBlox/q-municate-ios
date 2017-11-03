//
//  QMShareDialogsTableViewController.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/4/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBUUser;
@class QBChatDialog;
@class QMShareEtxentionOperation;

@protocol QMShareControllerDelegate <NSObject>

- (void)didTapShareButtonWithSelectedItems:(NSArray *)selectedItems;
- (void)didTapCancelButton;
- (void)didCancelSharing;

@end


@interface QMShareDialogsTableViewController : UITableViewController

@property (nonatomic, strong) NSArray <QBUUser *> *contactsToShare;
@property (nonatomic, strong) NSArray <QBChatDialog *> *dialogsToShare;

@property (nonatomic, weak) id <QMShareControllerDelegate> shareControllerDelegate;

@end
