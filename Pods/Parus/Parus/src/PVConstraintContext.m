//
//  PVConstraintContext.m
//  Parus
//
//  Created by Алексей Демедецкий on 17.06.13.
//
//

#import "PVConstraintContext.h"

static NSString* const kLeftViewNotSet = @"LeftViewNotSet";
static NSString* const kLeftViewAttributeNotSet = @"LeftViewAttributeNotSet";
static NSString* const kRightViewIsNilButAttributeIsAttribute = @"RightViewIsNilButAttributeIsAttribute";
static NSString* const kRightViewIsNilButAttributeMultiplierNotZero = @"RightViewIsNilButAttributeMultiplierNotZero";
static NSString* const kRightViewAttributeIsNotAnAttribute = @"RightViewAttributeIsNotAnAttribute";
static NSString* const kRightViewAttributeMultiplierIsZero = @"RightViewAttributeMultiplierIsZero";

#define PVException(condition,name) if(!(condition)) [NSException raise:(name) format:nil];

@implementation PVConstraintContext

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.leftView = nil;
        self.leftAttribute = NSLayoutAttributeNotAnAttribute;
        self.relation = NSLayoutRelationEqual;
        self.rightView = nil;
        self.rightAttribute = NSLayoutAttributeNotAnAttribute;
        self.rightAtttributeMultiplier = 0.f;
        self.rightConstant = 0.f;
        self.priority = UILayoutPriorityRequired;
    }
    
    return self;
}

- (NSLayoutConstraint *)buildConstraint
{
    PVException(self.leftView != nil, kLeftViewNotSet);
    PVException(self.leftAttribute != NSLayoutAttributeNotAnAttribute, kLeftViewAttributeNotSet);
    
    if (self.rightView == nil)
    {
        PVException(self.rightAttribute == NSLayoutAttributeNotAnAttribute, kRightViewIsNilButAttributeIsAttribute);
        PVException((self.rightAtttributeMultiplier == 0.f), kRightViewIsNilButAttributeMultiplierNotZero);
    }
    
    if (self.rightView != nil)
    {
        PVException(self.rightAttribute != NSLayoutAttributeNotAnAttribute, kRightViewAttributeIsNotAnAttribute);
        PVException(self.rightAtttributeMultiplier != 0.f, kRightViewAttributeMultiplierIsZero);
    }
    
    NSLayoutConstraint* constraint =
    [NSLayoutConstraint constraintWithItem:self.leftView
                                 attribute:self.leftAttribute
                                 relatedBy:self.relation
                                    toItem:self.rightView
                                 attribute:self.rightAttribute
                                multiplier:self.rightAtttributeMultiplier
                                  constant:self.rightConstant];
    constraint.priority = self.priority;
    
    return constraint;
}

@end
