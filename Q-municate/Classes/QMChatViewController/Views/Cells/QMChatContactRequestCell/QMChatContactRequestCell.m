//
//  QMChatContactRequestCell.m
//  QMChatViewController
//
//  Created by Injoit on 14.05.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import "QMChatContactRequestCell.h"
#import "QMChatCellLayoutAttributes.h"

@implementation QMChatContactRequestCell

#pragma mark - Actions

- (IBAction)pressRejectRequestBtn:(id) sender {
    
    [self.actionsHandler chatContactRequestDidAccept:NO sender:self];
}

- (IBAction)pressAcceptBtn:(id) sender {
    
    [self.actionsHandler chatContactRequestDidAccept:YES sender:self];
}

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel contactRequestModel = {
        .staticContainerSize = CGSizeMake(225, 130)
    };
    
    return contactRequestModel;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    } else {
        return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
}

@end
