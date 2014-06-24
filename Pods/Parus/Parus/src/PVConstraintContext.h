//
//  PVConstraintContext.h
//  Parus
//
//  Created by Алексей Демедецкий on 17.06.13.
//
//

#import <Foundation/Foundation.h>

static NSString* const kLeftViewNotSet;
static NSString* const kLeftViewAttributeNotSet;
static NSString* const kRightViewIsNilButAttributeIsAttribute;
static NSString* const kRightViewIsNilButAttributeMultiplierNotZero;
static NSString* const kRightViewAttributeIsNotAnAttribute;
static NSString* const kRightViewAttributeMultiplierIsZero;

@interface PVConstraintContext : NSObject

@property (strong) UIView* leftView;
@property (assign) NSLayoutAttribute leftAttribute;
@property (assign) NSLayoutRelation relation;
@property (strong) UIView* rightView;
@property (assign) NSLayoutAttribute rightAttribute;
@property (assign) CGFloat rightAtttributeMultiplier;
@property (assign) CGFloat rightConstant;
@property (assign) UILayoutPriority priority;

- (NSLayoutConstraint*)buildConstraint;

@end
