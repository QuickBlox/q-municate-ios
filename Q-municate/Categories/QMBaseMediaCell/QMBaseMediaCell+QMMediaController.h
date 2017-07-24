//
//  QMBaseMediaCell+QMMediaController.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 7/17/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <QMBaseMediaCell.h>

@interface QMBaseMediaCell (QMMediaController)

- (void)updateWithAttachment:(QBChatAttachment *)attachment
                   messageID:(NSString *)messageID
                    dialogID:(NSString *)dialopgID;

@end
