//
//  PVVFLContext.m
//  Parus
//
//  Created by Andrey Moskvin on 8/2/13.
//
//

#import "PVVFLContext.h"

@implementation PVVFLContext

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.format = nil;
        self.alignmentOptions = NSLayoutFormatAlignmentMask;
        self.directionOptions = NSLayoutFormatDirectionMask;
        self.views = nil;
        self.metrics = nil;
    }
    return self;
}

- (NSLayoutFormatOptions)currentOptions
{
    NSLayoutFormatOptions opts = 0;
    if (self.alignmentOptions != NSLayoutFormatAlignmentMask)
    {
        opts |= self.alignmentOptions;
    }
    if (self.directionOptions != NSLayoutFormatDirectionMask)
    {
        opts |= self.directionOptions;
    }
    
    return opts;
}

- (NSArray *)buildConstraints
{
    NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:self.format
                                                                   options:[self currentOptions]
                                                                   metrics:self.metrics
                                                                     views:self.views];
    return constraints;
}

@end
