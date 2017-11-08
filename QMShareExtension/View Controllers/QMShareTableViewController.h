//
//  QMShareTableViewController.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/4/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMShareDataSource.h"


@class QBUUser;
@class QBChatDialog;

@protocol QMShareItemProtocol;

NS_ASSUME_NONNULL_BEGIN
@protocol QMShareControllerDelegate <NSObject>

- (void)didTapShareBarButtonWithSelectedItems:(NSArray<id<QMShareItemProtocol>> *)selectedItems;
- (void)didTapCancelBarButton;
- (void)didCancelSharing;

@end

@interface QMShareTableViewController : UITableViewController

+ (instancetype)qm_shareTableViewControllerWithDialogs:(NSArray *)dialogs
                                              contacts:(NSArray * _Nullable )contacts;

- (void)showLoadingAlertControllerWithStatus:(NSString *)status
                                    animated:(BOOL)animated
                              withCompletion:(_Nullable dispatch_block_t)completion;

- (void)dismissLoadingAlertControllerAnimated:(BOOL)animated
                               withCompletion:(_Nullable dispatch_block_t)completion;


@property (nonatomic, strong, readonly) QMShareDataSource *shareDataSource;
@property (nonatomic, strong, readonly) QMShareSearchControllerDataSource *searchDataSource;

@property (nonatomic, weak) id <QMShareControllerDelegate> shareControllerDelegate;

@end

NS_ASSUME_NONNULL_END
