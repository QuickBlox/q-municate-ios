#import "CDDialog.h"

@interface CDDialog ()

@end

@implementation CDDialog

- (QBChatDialog *)toQBChatDialog {
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] init];
    
    chatDialog.ID = self.id;
    chatDialog.roomJID = self.roomJID;
    chatDialog.type = self.type.intValue;
    chatDialog.name = self.name;
    
    return chatDialog;
}

- (void)updateWithQBChatDialog:(QBChatDialog *)dialog {

    self.id = dialog.ID;
    self.roomJID = dialog.roomJID;
    self.type = @(dialog.type);
    self.name = dialog.name;    
}

@end
