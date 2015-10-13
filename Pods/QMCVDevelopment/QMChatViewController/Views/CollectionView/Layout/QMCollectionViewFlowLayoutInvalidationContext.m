//
//  QMCollectionViewFlowLayoutInvalidationContext.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMCollectionViewFlowLayoutInvalidationContext.h"

@implementation QMCollectionViewFlowLayoutInvalidationContext

#pragma mark - Initialization

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.invalidateFlowLayoutDelegateMetrics = NO;
        self.invalidateFlowLayoutAttributes = NO;
        _invalidateFlowLayoutMessagesCache = NO;
    }
    return self;
}

+ (instancetype)context {
    
    QMCollectionViewFlowLayoutInvalidationContext *context =
    [[QMCollectionViewFlowLayoutInvalidationContext alloc] init];
    
    context.invalidateFlowLayoutDelegateMetrics = YES;
    context.invalidateFlowLayoutAttributes = YES;
    
    return context;
}

#pragma mark - NSObject

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@: invalidateFlowLayoutDelegateMetrics=%@, invalidateFlowLayoutAttributes=%@, invalidateDataSourceCounts=%@, invalidateFlowLayoutMessagesCache=%@>",
            [self class],
            @(self.invalidateFlowLayoutDelegateMetrics),
            @(self.invalidateFlowLayoutAttributes),
            @(self.invalidateDataSourceCounts),
            @(self.invalidateFlowLayoutMessagesCache)];
}

@end
