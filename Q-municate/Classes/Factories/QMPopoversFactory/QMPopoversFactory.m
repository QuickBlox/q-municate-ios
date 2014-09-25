//
//  QMPopoversFactory.m
//  Q-municate
//
//  Created by Igor Alefirenko on 23.09.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMPopoversFactory.h"
#import "QMChatViewController.h"
#import "QMApi.h"

@implementation QMPopoversFactory


+ (QMChatViewController *)chatControllerWithDialogID:(NSString *)dialogID
{
    QBChatDialog *dialog = [[QMApi instance] chatDialogWithID:dialogID];
    
    QMChatViewController *chatVC = (QMChatViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"QMChatViewController"];
    chatVC.dialog = dialog;
    return chatVC;
}

@end
