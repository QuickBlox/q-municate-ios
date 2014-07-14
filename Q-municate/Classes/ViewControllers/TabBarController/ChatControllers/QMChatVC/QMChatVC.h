//
//  QMChatVC.h
//  Q-municate
//
//  Created by Andrey on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMChatDataSource;
@class QMChatInputToolbar;

@interface QMChatVC : UIViewController

@property (strong, nonatomic, readonly) UITableView *tableView;
@property (strong, nonatomic) QMChatDataSource *dataSource;
/**
 *  Returns the input toolbar view object managed by this view controller.
 *  This view controller is the toolbar's delegate.
 */
@property (strong, nonatomic, readonly) QMChatInputToolbar *inputView;
/**
 *  Specifies whether or not the view controller should automatically scroll to the most recent message
 *  when the view appears and when sending, receiving, and composing a new message.
 *
 *  @discussion The default value is `YES`, which allows the view controller to scroll automatically to the most recent message.
 *  Set to `NO` if you want to manage scrolling yourself.
 */
@property (assign, nonatomic) BOOL automaticallyScrollsToMostRecentMessage;
/**
 *  Scrolls the collection view such that the bottom most cell is completely visible, above the `inputView`.
 *
 *  @param animated Pass `YES` if you want to animate scrolling, `NO` if it should be immediate.
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

@end
