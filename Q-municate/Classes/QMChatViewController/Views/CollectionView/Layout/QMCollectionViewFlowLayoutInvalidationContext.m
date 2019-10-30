//
//  QMCollectionViewFlowLayoutInvalidationContext.m
//  QMChatViewController
//
//  Created by Injoit on 20.04.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import "QMCollectionViewFlowLayoutInvalidationContext.h"

@implementation QMCollectionViewFlowLayoutInvalidationContext

#pragma mark - Initialization

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _invalidateFlowLayoutMessagesCache = NO;
    }
    return self;
}

+ (instancetype)context {
    
    return [[QMCollectionViewFlowLayoutInvalidationContext alloc] init];
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
