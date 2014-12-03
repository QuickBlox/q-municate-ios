//
//  QMConnectionManager.m
//  Q-municate
//
//  Created by Igor Alefirenko on 01.12.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMConnectionManager.h"
#import <Reachability.h>


@interface QMConnectionManager()

@property (strong, nonatomic) Reachability *internetConnection;

@end

@implementation QMConnectionManager


- (instancetype)init
{
    if (self = [super init]) {
        self.internetConnection = [Reachability reachabilityForInternetConnection];
        [self.internetConnection startNotifier];
    }
    return self;
}



@end
