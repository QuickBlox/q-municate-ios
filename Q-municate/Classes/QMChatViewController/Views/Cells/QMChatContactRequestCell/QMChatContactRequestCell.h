//
//  QMChatContactRequestCell.h
//  QMChatViewController
//
//  Created by Injoit on 14.05.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import "QMChatCell.h"
#import "QMChatActionsHandler.h"

@protocol QMChatContactRequestCellActions;

/**
 *  Contact request cell, includes accept/reject actions delegate.
 */
@interface QMChatContactRequestCell : QMChatCell

@property (weak, nonatomic) id <QMChatActionsHandler> actionsHandler;

@end

