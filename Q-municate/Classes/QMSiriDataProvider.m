//
//  QMSiriDataProvider.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSiriDataProvider.h"
#import "QMCore.h"

@implementation QMSiriDataProvider

+ (instancetype)instance {
    static QMSiriDataProvider *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QMSiriDataProvider alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (BOOL)isAuthorized {
    return  [QMCore instance].currentProfile != nil;
}

@end
