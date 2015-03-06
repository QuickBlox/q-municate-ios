//
//  QBEchoObject.m
//  QBEchoObject
//
//  Created by Glebus on 03.10.12.
//
//

#import "QBEchoObject.h"
#import <Quickblox/Quickblox.h>

@implementation QBEchoObject

static QBEchoObject *instance = nil;

+ (QBEchoObject *)instance
{
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
	
    return instance;
}

+ (void *)makeBlockForEchoObject:(id)originBlock
{
    return Block_copy((__bridge void*)originBlock);
}

- (void)completedWithResult:(QBResult *)result context:(void *)contextInfo
{
    ((__bridge void (^)(QBResult * result))(contextInfo))(result);
    Block_release(contextInfo);
}

- (void)completedWithResult:(QBResult *)result
{
	
}

@end
