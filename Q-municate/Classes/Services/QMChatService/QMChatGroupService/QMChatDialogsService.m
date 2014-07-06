//
//  QMChatDialogsService.m
//  Qmunicate
//
//  Created by Andrey on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatDialogsService.h"
#import "QBEchoObject.h"

@implementation QMChatDialogsService

- (void)fetchAllDialogs:(QBDialogsPagedResultBlock)completion {
    //    self.allDialogsAsDictionary = [self dialogsAsDictionaryFromDialogsArray:dialogs];
    [QBChat dialogsWithDelegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

/*Create group dialog*/

- (void)createChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
	[QBChat createDialog:chatDialog delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (void)updateChatDialogWithID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest completion:(QBChatDialogResultBlock)completion {
    //    self.allDialogsAsDictionary[chatDialog.roomJID] = chatDialog;
    
    [QBChat updateDialogWithID:dialogID
               extendedRequest:extendedRequest
                      delegate:[QBEchoObject instance]
                       context:[QBEchoObject makeBlockForEchoObject:completion]];
}


@end
