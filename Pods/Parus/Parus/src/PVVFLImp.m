//
//  PVVFL.m
//  Parus
//
//  Created by Andrey Moskvin on 6/21/13.
//
//

#import "PVVFLImp.h"
#import "PVVFL.h"
#import "PVVFLContext.h"

@implementation PVVFLLayout

-(instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _context = [PVVFLContext new];
    }
    return self;
}

@end

@interface PVVFLLayout (PVAlignmentOptionSelect) <_PVAlignmentOptionSelect>

@end

@interface PVVFLLayout (DirectionOptionSelect) <_PVDirectionOptionSelect>

@end

@interface PVVFLLayout (ViewsPart) <_PVViewsPart>

@end

@interface PVVFLLayout (MetricsPart) <_PVMetricsPart>

@end

@interface PVVFLLayout (ArrayConstrainable) <_PVArrayConstrainable>

@end

@implementation PVVFLLayout (DirectionOptionSelect)

-(NSObject<_PVViewsPart> *)fromLeadingToTrailing
{
    return [self directionOptionPart:NSLayoutFormatDirectionLeadingToTrailing];
}

-(NSObject<_PVViewsPart> *)fromLeftToRight
{
    return [self directionOptionPart:NSLayoutFormatDirectionLeftToRight];
}

-(NSObject<_PVViewsPart> *)fromRightToLeft
{
    return [self directionOptionPart:NSLayoutFormatDirectionRightToLeft];
}

-(NSObject<_PVViewsPart> *)directionOptionPart:(NSLayoutFormatOptions)options
{
    NSAssert(self.context != nil, @"Context is not set");
    
    self.context.directionOptions = options;
    
    return self;
}

@end

@implementation PVVFLLayout (PVAlignmentOptionSelect)

-(NSObject<_PVDirectionOptionSelect> *)alignAllLeft
{
    return [self alignmentOptionPart:NSLayoutFormatAlignAllLeft];
}

-(NSObject<_PVDirectionOptionSelect> *)alignAllRight
{
    return [self alignmentOptionPart:NSLayoutFormatAlignAllRight];
}

-(NSObject<_PVDirectionOptionSelect> *)alignAllLeftAndRight
{
    return [self alignmentOptionPart:(NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight)];
}

-(NSObject<_PVDirectionOptionSelect> *)alignAllTop
{
    return [self alignmentOptionPart:NSLayoutFormatAlignAllTop];
}

-(NSObject<_PVDirectionOptionSelect> *)alignAllBottom
{
    return [self alignmentOptionPart:NSLayoutFormatAlignAllBottom];
}

-(NSObject<_PVDirectionOptionSelect> *)alignAllTopAndBottom
{
    return [self alignmentOptionPart:(NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom)];
}

-(NSObject<_PVDirectionOptionSelect> *)alignAllLeading
{
    return [self alignmentOptionPart:NSLayoutFormatAlignAllLeading];
}

-(NSObject<_PVDirectionOptionSelect> *)alignAllTrailing
{
    return [self alignmentOptionPart:NSLayoutFormatAlignAllTrailing];
}

-(NSObject<_PVDirectionOptionSelect> *)alignAllLeadingAndTrailing
{
    return [self alignmentOptionPart:(NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing)];
}

-(NSObject<_PVDirectionOptionSelect> *)alignAllCenterX
{
    return [self alignmentOptionPart:NSLayoutFormatAlignAllCenterX];
}

-(NSObject<_PVDirectionOptionSelect> *)alignAllCenterY
{
    return [self alignmentOptionPart:NSLayoutFormatAlignAllCenterY];
}

-(NSObject<_PVDirectionOptionSelect> *)alignAllBaseline
{
    return [self alignmentOptionPart:NSLayoutFormatAlignAllBaseline];
}

-(NSObject<_PVDirectionOptionSelect> *)alignmentOptionPart:(NSLayoutFormatOptions)options
{
    NSAssert(self.context != nil, @"Context is not set");
    
    self.context.alignmentOptions = options;
    
    return self;
}

@end

@implementation PVVFLLayout (ViewsPart)

-(_PVViewsPartBlock)withViews
{
    return ^(NSDictionary* views)
    {
        NSAssert(self.context != nil, @"Context is not set");
        
        self.context.views = views;
        
        return (_PVMetricsPart*)self;
    };
}

@end

@implementation PVVFLLayout (MetricsPart)

-(_PVMetricsBlock)metrics
{
    return ^(NSDictionary *metrics)
    {
        NSAssert(self.context != nil, @"Context is not set");
        
        self.context.metrics = metrics;
        
        return (_PVArrayConstrainable*)self;
    };
}

@end

@implementation PVVFLLayout (ArrayConstrainable)

-(NSArray *)asArray
{
    NSAssert(self.context != nil, @"Context is not set");

    return [self.context buildConstraints];
}

@end

_PVAlignmentOptionSelect* PVVFL(NSString* format)
{
    NSCAssert([format isKindOfClass:[NSString class]], @"Format should be NSString");

    PVVFLLayout* layout = [PVVFLLayout new];
    layout.context.format = format;
    
    return (_PVAlignmentOptionSelect*)layout;
}
