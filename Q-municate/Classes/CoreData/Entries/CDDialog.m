#import "CDDialog.h"

@interface CDDialog ()

@end

@implementation CDDialog

- (QBChatDialog *)toQBChatDialog {
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:self.id type:self.dialogType.intValue];
    
    chatDialog.roomJID = self.roomJID;
    chatDialog.name = self.name;
    
    return chatDialog;
}

- (void)updateWithQBChatDialog:(QBChatDialog *)dialog {

    self.id = dialog.ID;
    self.roomJID = dialog.roomJID;
    self.dialogType = @(dialog.type);
    self.name = dialog.name;    
}

@end
