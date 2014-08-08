//
//  PVGroupImpl.m
//  Parus
//
//  Created by Алексей Демедецкий on 10.08.13.
//
//

#import "PVGroupImpl.h"
#import "PVGroup.h"
#import "PVGroupContext.h"

#import "PVLayoutImp.h"
#import "PVVFLImp.h"
#import "PVVFLContext.h"

@interface PVGroupImpl ()<_PVGroupProtocol>

@property (copy) NSArray* array;

@end

_PVGroup* PVGroup(NSArray* array)
{
    return ({
        PVGroupImpl* group = [PVGroupImpl new];
        group.array = array;
        
        (_PVGroup*)group;
    });
}

@implementation PVGroupImpl

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _context = [PVGroupContext new];
    }
    return self;
}

+ (void)applyGroupContext:(PVGroupContext*)groupContext
              toVFLContxt:(PVVFLContext*)VFLContext
{
    {
        NSMutableDictionary* result = [NSMutableDictionary dictionary];
        [result addEntriesFromDictionary:groupContext.views];
        [result addEntriesFromDictionary:VFLContext.views];
        
        VFLContext.views = [result copy];
    }
    {
        NSMutableDictionary* result = [NSMutableDictionary dictionary];
        [result addEntriesFromDictionary:groupContext.metrics];
        [result addEntriesFromDictionary:VFLContext.metrics];
        
        VFLContext.metrics = [result copy];
    }
    {
        BOOL isSettedInGroup = (groupContext.direction != NSLayoutFormatDirectionMask);
        BOOL isSettedInVFL = (VFLContext.directionOptions != NSLayoutFormatDirectionMask);

        if (isSettedInGroup && !isSettedInVFL)
        {
            VFLContext.directionOptions = groupContext.direction;
        }
    }
}


#pragma mark - Array conversion

- (NSArray *)asArray
{
    NSMutableArray* result = [NSMutableArray new];
    for (id object in self.array)
    {
        if ([object isKindOfClass:[NSArray class]])
        {
            [result addObjectsFromArray:object];
        }
        else if ([object isKindOfClass:[NSLayoutConstraint class]])
        {
            [result addObject:object];
        }
        else if ([object isKindOfClass:[PVLayout class]])
        {
            PVLayout* l = object;
            [result addObject:[l.context buildConstraint]];
        }
        else if ([object isKindOfClass:[PVVFLLayout class]])
        {
            PVVFLLayout* l = object;
            [self.class applyGroupContext:self.context
                              toVFLContxt:l.context];
            [result addObjectsFromArray:[l.context buildConstraints]];
        }
    }
    
    return [result copy];
}

#pragma mark - Metrics

- (_PVGroupWithMetricsBlock)withMetrics
{
    return ^(NSDictionary* metrics){
        self.context.metrics = metrics;
        return (_PVGroupWithMetricsResult)self;
    };
}

#pragma mark - Views

- (_PVGroupWithViewsBlock)withViews
{
    return ^(NSDictionary* views){
        self.context.views = views;
        return (_PVGroupWithViewsResult*)self;
    };
}

#pragma mark - Direction

- (_PVGroupDiretionChooseResult*)applyDirection:(NSLayoutFormatOptions)opt
{
    self.context.direction = opt;
    return (_PVGroupDiretionChooseResult*)self;
}

- (_PVGroupDiretionChooseResult*)fromLeadingToTrailing
{
    return [self applyDirection:NSLayoutFormatDirectionLeadingToTrailing];
}

- (_PVGroupDiretionChooseResult*)fromLeftToRight
{
    return [self applyDirection:NSLayoutFormatDirectionLeftToRight];
}

- (_PVGroupDiretionChooseResult*)fromRightToLeft
{
    return [self applyDirection:NSLayoutFormatDirectionRightToLeft];
}

@end
