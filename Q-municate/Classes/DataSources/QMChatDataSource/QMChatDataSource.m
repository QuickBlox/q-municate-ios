//
//  QMChatDataSource.m
//  Q-municate
//
//  Created by Igor Alefirenko on 01/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatDataSource.h"
#import "QMChatViewCell.h"


@implementation QMChatDataSource
@synthesize chatHistory;

- (id)init
{
    self = [super init];
    if (self) {
        self.chatHistory = @[@{@"name":@"Oleg Svarovski",
                @"text":@"Hi there!",
                @"date":@"12 Jan"},
                @{@"name":@"James Cobs",
                        @"text":@"Hi. How are you doing man?",
                        @"date":@"12 Jan"},
                @{@"name":@"Jessica Alba",
                        @"text":@"Hi guys, I'm so alone right now... Let's talk? :)",
                        @"date":@"16:04"},
                @{@"name":@"Eric Sweedich",
                        @"text":@"I love u, Jessica!!! I cann't live, i cann't breathe without you! Come baaaack!",
                        @"date":@"17:28"},
                @{@"name":@"Dan Malkov",
                        @"text":@"iwoej piowje peioj aso hqiohfaposif hbqlifh axo iqhgfpoiaxg fqgwhpqsia hfcpqhiagoc vqhdp   whbdpiashcoiawglaeveqwg oiqg coiq ghqoiliqwh dqwb oqhcocoqw",
                        @"date":@"17:33"},
                @{@"name":@"Jack Merk",
                        @"text":@"Ha ha ha!",
                        @"date":@"17:39"}];
    }
    return self;
}

@end
