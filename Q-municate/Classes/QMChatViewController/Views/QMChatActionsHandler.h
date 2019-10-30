//
//  QMChatActionsHandler.h
//  QMChatViewController
//
//  Created by Injoit on 29.05.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QMChatActionsHandler <NSObject>

- (void)chatContactRequestDidAccept:(BOOL)accept sender:(id)sender;

@end
