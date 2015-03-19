//
//  QMChatVC.h
//  Q-municate
//
//  Created by Andrey Ivanov on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMChatDataSource;
@class QMChatInputToolbar;
@class QMApi;

@interface QMChatVC : UIViewController
{
    QMApi *api;
}
@property (strong, nonatomic, readonly) UITableView *tableView;

@property (strong, nonatomic) QMChatDataSource *dataSource;
/**
 *  Returns the input toolbar view object managed by this view controller.
 *  This view controller is the toolbar's delegate.
 */
@property (strong, nonatomic, readonly) QMChatInputToolbar *inputToolBar;
/**
 *  Scrolls the collection view such that the bottom most cell is completely visible, above the `inputView`.
 *
 *  @param animated Pass `YES` if you want to animate scrolling, `NO` if it should be immediate.
 */

@property (strong, nonatomic) QBChatDialog *dialog;

@end
