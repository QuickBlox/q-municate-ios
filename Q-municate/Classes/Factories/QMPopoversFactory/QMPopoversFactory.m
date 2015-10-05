//
//  QMPopoversFactory.m
//  Q-municate
//
//  Created by Igor Alefirenko on 23.09.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMPopoversFactory.h"
#import "QMChatVC.h"
#import "QMApi.h"

@implementation QMPopoversFactory


+ (UIViewController *)chatControllerWithDialogID:(NSString *)dialogID
{
    QBChatDialog *dialog = [[QMApi instance] chatDialogWithID:dialogID];
    
    QMChatVC *chatVC = (QMChatVC *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"QMChatVC"];
    chatVC.dialog = dialog;
    return chatVC;
}

@end
