//
//  QMUploadAttachCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 29/05/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUploadAttachCell.h"
#import "QMChatService.h"

@implementation QMUploadAttachCell
@synthesize isLoadBegan;

- (void)awakeFromNib
{
    // Initialization code
    if (!self.uploadManager) {
        self.uploadManager = [[QMContent alloc] init];
    }
}

- (void)configureCellWithMessage:(QMChatUploadingMessage *)uploadMessage
{
    if (isLoadBegan) {
        return;
    }
    isLoadBegan = YES;
    [self.uploadManager uploadImage:uploadMessage.content withCompletion:^(QBCBlob *blob, BOOL success, NSError *error) {
        
        // create content message and send:
        [[QMChatService shared] sendContentMessage:uploadMessage withBlob:blob];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ContentDidLoadNotification" object:nil];
        isLoadBegan = NO;
    }];
}

@end
