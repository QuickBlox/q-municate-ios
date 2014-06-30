//
//  QMUploadAttachCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 29/05/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMContent.h"
#import "QMChatUploadingMessage.h"

@interface QMUploadAttachCell : UITableViewCell

@property (strong) QMContent *uploadManager;
@property (nonatomic, assign) BOOL isLoadBegan;

- (void)configureCellWithMessage:(QMChatUploadingMessage *)uploadMessage;

@end
