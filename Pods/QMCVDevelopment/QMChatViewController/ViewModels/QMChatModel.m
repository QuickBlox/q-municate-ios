//
//  QMChatModel.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 5/30/17.
//
//

#import "QMChatModel.h"
@interface QMChatModel()

@end

@implementation QMChatModel

@synthesize modelID = _modelID;
@synthesize modelContentType = _modelContentType;

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@: %p; modelID =>",
            NSStringFromClass([self class]),
            self.modelID];
}

@end
