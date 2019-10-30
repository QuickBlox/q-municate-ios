#import "_QMCDDialog.h"
#import <Quickblox/Quickblox.h>

@interface QMCDDialog : _QMCDDialog {}

- (QBChatDialog *)toQBChatDialog;
- (void)updateWithQBChatDialog:(QBChatDialog *)dialog;

@end

@interface NSArray(QMCDDialog)

- (NSArray<QBChatDialog *> *)toQBChatDialogs;

@end
