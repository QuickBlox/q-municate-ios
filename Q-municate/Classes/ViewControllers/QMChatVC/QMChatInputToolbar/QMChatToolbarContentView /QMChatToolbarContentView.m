//
//  QMChatToolbarContentView.m
//  Qmunicate
//
//  Created by Andrey on 20.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatToolbarContentView.h"
#import "QMChatInputTextView.h"
#import "Parus.h"

@interface QMChatToolbarContentView()

@property (strong, nonatomic) UIView *leftBarButtonContainerView;
@property (strong, nonatomic) UIView *rightBarButtonContainerView;
@property (strong, nonatomic) QMChatInputTextView *textView;

@property (strong, nonatomic) NSLayoutConstraint *rightBarButtonContainerViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *leftBarButtonContainerViewWidthConstraint;

@end

@implementation QMChatToolbarContentView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configureChatToolbarContentView];
        
        //        self.leftBarButtonItem = nil;
        //        self.rightBarButtonItem = nil;
    }
    
    return self;
}

- (void)dealloc {
    
    _textView = nil;
    _leftBarButtonItem = nil;
    _rightBarButtonItem = nil;
    _leftBarButtonContainerView = nil;
    _rightBarButtonContainerView = nil;
}

- (void)configureChatToolbarContentView {
    
    self.leftBarButtonContainerView = [[UIView alloc] init];
    self.rightBarButtonContainerView = [[UIView alloc] init];
    self.textView = [[QMChatInputTextView alloc] init];
    
    self.textView.placeHolder = @"input text here...";
    self.textView.placeHolderTextColor = [UIColor grayColor];
    
    [self addSubview:self.leftBarButtonContainerView];
    [self addSubview:self.textView];
    [self addSubview:self.rightBarButtonContainerView];
    
    [self configureConstraints];
}

- (void)configureConstraints {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.leftBarButtonContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightBarButtonContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *constrains = [NSMutableArray array];
    
    UIView *lView = self.leftBarButtonContainerView;
    UIView *cView = self.textView;
    UIView *rView = self.rightBarButtonContainerView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(lView, cView, rView);
    
    [constrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[lView][cView][rView]|"
                                                                            options:NSLayoutFormatAlignAllBottom
                                                                            metrics:nil
                                                                              views:views]];
    
    [self addConstraints:constrains];
    
//    [constrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-pading-[lView(50)]-pading-[cView]-pading-[rView(50)]-pading-|"
//                                                                            options:(NSLayoutFormatAlignAllBottom)
//                                                                            metrics:@{@"pading" : @4}
//                                                                              views:views]];
//    [constrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[lView(50)][cView][rView(50)]|"
//                                                                            options:(NSLayoutFormatAlignAllCenterY)
//                                                                            metrics:nil
//                                                                              views:views]];
    
    //    /*Left container*/
    //    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.leftBarButtonContainerView
    //                                                       attribute:NSLayoutAttributeWidth
    //                                                       relatedBy:NSLayoutRelationEqual
    //                                                          toItem:nil
    //                                                       attribute:NSLayoutAttributeNotAnAttribute
    //                                                      multiplier:1.f
    //                                                        constant:60]];
    //
    //    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.leftBarButtonContainerView
    //                                                       attribute:NSLayoutAttributeHeight
    //                                                       relatedBy:NSLayoutRelationEqual
    //                                                          toItem:nil
    //                                                       attribute:NSLayoutAttributeNotAnAttribute
    //                                                      multiplier:1.f
    //                                                        constant:34]];
    //
    //    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.leftBarButtonContainerView
    //                                                       attribute:NSLayoutAttributeBottom
    //                                                       relatedBy:NSLayoutRelationEqual
    //                                                          toItem:self
    //                                                       attribute:NSLayoutAttributeBottom
    //                                                      multiplier:1.f
    //                                                        constant:0]];
    //
    //    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.leftBarButtonContainerView
    //                                                       attribute:NSLayoutAttributeLeft
    //                                                       relatedBy:NSLayoutRelationEqual
    //                                                          toItem:self
    //                                                       attribute:NSLayoutAttributeLeft
    //                                                      multiplier:1.f
    //                                                        constant:2]];
    //    /*Right constainer*/
    //    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.rightBarButtonContainerView
    //                                                       attribute:NSLayoutAttributeWidth
    //                                                       relatedBy:NSLayoutRelationEqual
    //                                                          toItem:nil
    //                                                       attribute:NSLayoutAttributeNotAnAttribute
    //                                                      multiplier:1.f
    //                                                        constant:60]];
    //
    //    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.rightBarButtonContainerView
    //                                                       attribute:NSLayoutAttributeHeight
    //                                                       relatedBy:NSLayoutRelationEqual
    //                                                          toItem:nil
    //                                                       attribute:NSLayoutAttributeNotAnAttribute
    //                                                      multiplier:1.f
    //                                                        constant:34]];
    //
    //    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.rightBarButtonContainerView
    //                                                       attribute:NSLayoutAttributeBottom
    //                                                       relatedBy:NSLayoutRelationEqual
    //                                                          toItem:self
    //                                                       attribute:NSLayoutAttributeBottom
    //                                                      multiplier:1.f
    //                                                        constant:0]];
    //
    //    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.rightBarButtonContainerView
    //                                                       attribute:NSLayoutAttributeRight
    //                                                       relatedBy:NSLayoutRelationEqual
    //                                                          toItem:self
    //                                                       attribute:NSLayoutAttributeRight
    //                                                      multiplier:1.f
    //                                                        constant:2]];
    //    /*Center view*/
    //    [constrains addObject:[NSLayoutConstraint constraintWithItem:self.textView
    //                                                       attribute:NSLayoutAttributeHeight
    //                                                       relatedBy:NSLayoutRelationEqual
    //                                                          toItem:nil
    //                                                       attribute:NSLayoutAttributeNotAnAttribute
    //                                                      multiplier:1.f
    //                                                        constant:34]];
    //
    
    //
    //    self.leftBarButtonContainerViewWidthConstraint = constrains[0];
    //    self.rightBarButtonContainerViewWidthConstraint = constrains[2];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
}

#pragma mark - Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    
    [super setBackgroundColor:backgroundColor];
    self.leftBarButtonContainerView.backgroundColor = backgroundColor;
    self.rightBarButtonContainerView.backgroundColor = backgroundColor;
}

- (void)setLeftBarButtonItem:(UIButton *)leftBarButtonItem {
    
    if (_leftBarButtonItem) {
        [_leftBarButtonItem removeFromSuperview];
    }
    
    if (!leftBarButtonItem) {
        
        self.leftBarButtonItemWidth = 0.0f;
        _leftBarButtonItem = nil;
        self.leftBarButtonContainerView.hidden = YES;
        return;
    }
    
    if (CGRectEqualToRect(_leftBarButtonItem.frame, CGRectZero)) {
        _leftBarButtonItem.frame = CGRectMake(0.0f,
                                              0.0f,
                                              CGRectGetWidth(self.leftBarButtonContainerView.frame),
                                              CGRectGetHeight(self.leftBarButtonContainerView.frame));
    }
    
    leftBarButtonItem.translatesAutoresizingMaskIntoConstraints = NO;
    self.leftBarButtonContainerView.hidden = NO;
    
    [self.leftBarButtonContainerView addSubview:leftBarButtonItem];
//    [self addConstraints:PVGroup(@[PVTopOf(self).equalTo.topOf(self.leftBarButtonContainerView),
//                                                              PVBottomOf(self).equalTo.bottomOf(se.)]).asArray];
//    [self.leftBarButtonContainerView pinAllEdgesOfSubview:leftBarButtonItem];
    
    [self setNeedsUpdateConstraints];
    
    _leftBarButtonItem = leftBarButtonItem;
}

- (void)setLeftBarButtonItemWidth:(CGFloat)leftBarButtonItemWidth {
    
    self.leftBarButtonContainerViewWidthConstraint.constant = leftBarButtonItemWidth;
    [self setNeedsUpdateConstraints];
}

- (void)setRightBarButtonItem:(UIButton *)rightBarButtonItem {
    
    if (_rightBarButtonItem) {
        [_rightBarButtonItem removeFromSuperview];
    }
    
    if (!rightBarButtonItem) {
        
        self.rightBarButtonItemWidth = 0.0f;
        _rightBarButtonItem = nil;
        self.rightBarButtonContainerView.hidden = YES;
        return;
    }
    
    rightBarButtonItem.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.rightBarButtonContainerView.hidden = NO;
    
    if (CGRectEqualToRect(_rightBarButtonItem.frame, CGRectZero)) {
        _rightBarButtonItem.frame = CGRectMake(0.0f,
                                               0.0f,
                                               CGRectGetWidth(self.rightBarButtonContainerView.frame),
                                               CGRectGetHeight(self.rightBarButtonContainerView.frame));
    }
    
    [self.rightBarButtonContainerView addSubview:rightBarButtonItem];
//    [self.rightBarButtonContainerView pinAllEdgesOfSubview:rightBarButtonItem];
    [self setNeedsUpdateConstraints];
    
    _rightBarButtonItem = rightBarButtonItem;
}

- (void)setRightBarButtonItemWidth:(CGFloat)rightBarButtonItemWidth {
    
    self.rightBarButtonContainerViewWidthConstraint.constant = rightBarButtonItemWidth;
    [self setNeedsUpdateConstraints];
}

#pragma mark - Getters

- (CGFloat)leftBarButtonItemWidth {
    
    return self.leftBarButtonContainerViewWidthConstraint.constant;
}

- (CGFloat)rightBarButtonItemWidth {
    
    return self.rightBarButtonContainerViewWidthConstraint.constant;
}

#pragma mark - UIView overrides

- (void)setNeedsDisplay {
    
    [super setNeedsDisplay];
    [self.textView setNeedsDisplay];
}

@end
