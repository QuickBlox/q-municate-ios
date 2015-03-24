//
//  REMailCompose.m
//  Q-municate
//
//  Created by Andrey Ivanov on 07.01.14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "REMessageUI.h"

@interface REMailComposeViewController ()
<MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, copy) MFMailComposeResultBlock resultBlock;

@end

@implementation REMailComposeViewController

- (id)init{
    self = [super init];
    if (self) {
        self.mailComposeDelegate = self;
    }
    return self;
}

+ (void)present:(void(^)(REMailComposeViewController *mailVC))mailComposeViewController finish:(MFMailComposeResultBlock)finish {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        REMailComposeViewController *mailVC = [REMailComposeViewController new];
        mailVC.resultBlock = finish;
        mailComposeViewController(mailVC);
    }else {
        finish(MFMailComposeResultFailed, nil);
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    __weak __typeof(self)weakSelf = self;
    [controller dismissViewControllerAnimated:YES completion:^{
        weakSelf.resultBlock(result, error);
        weakSelf.resultBlock = nil;
    }];
}

@end

@interface REMessageComposeViewController ()

<MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>

@property (copy, nonatomic) MessageComposeResultBlock resultBlock;

@end

@implementation REMessageComposeViewController

- (id)init {
    self = [super init];
    if (self) {
        self.messageComposeDelegate = self;
    }
    return self;
}

+ (void)present:(void(^)(REMessageComposeViewController *massageVC))messageComposeViewController
         finish:(void(^)(MessageComposeResult result))finish {
    
    if ([MFMessageComposeViewController canSendText]) {
        
        REMessageComposeViewController *messageVC = [REMessageComposeViewController new];
        messageVC.resultBlock = finish;
        messageComposeViewController(messageVC);
    } else {
        finish(MessageComposeResultFailed);
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    __weak __typeof(self)weakSelf = self;
    [controller dismissViewControllerAnimated:YES completion:^{
        weakSelf.resultBlock(result);
        weakSelf.resultBlock = nil;
    }];
}

@end
