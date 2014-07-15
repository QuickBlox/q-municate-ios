//
//  REMailCompose.h
//  Q-municate
//
//  Created by Andrey Ivanov on 07.01.14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <MessageUI/MessageUI.h>

typedef void(^MFMailComposeResultBlock)(MFMailComposeResult result, NSError *error);
typedef void(^MessageComposeResultBlock)(MessageComposeResult result);

@class REMailComposeViewController;

@interface REMailComposeViewController : MFMailComposeViewController

+ (void)present:(void(^)(REMailComposeViewController *mailVC))mailComposeViewController
         finish:(MFMailComposeResultBlock)finish;

@end

@interface REMessageComposeViewController : MFMessageComposeViewController

+ (void)present:(void(^)(REMessageComposeViewController *massageVC))messageComposeViewController
         finish:(void(^)(MessageComposeResult result))finish;

@end



