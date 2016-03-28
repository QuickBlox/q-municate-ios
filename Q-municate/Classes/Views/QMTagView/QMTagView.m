//
//  QMTagView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTagView.h"

static UIImage *tokenBackgroundImage() {
    
    static UIImage *image = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        UIImage *rawImage = [UIImage imageNamed:@"qm-bg-tag"];
        image = [rawImage stretchableImageWithLeftCapWidth:(NSInteger)(rawImage.size.width / 2) topCapHeight:0];
    });
    
    return image;
}

static UIImage *tokenBackgroundHighlightedImage() {
    
    static UIImage *image = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        UIImage *rawImage = [UIImage imageNamed:@"qm-bg-tag-highlighted"];
        image = [rawImage stretchableImageWithLeftCapWidth:(NSInteger)(rawImage.size.width / 2) topCapHeight:0];
    });
    
    return image;
}

@implementation QMTagView

#pragma mark - Constructors

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    [self setBackgroundImage:tokenBackgroundImage() forState:UIControlStateNormal];
    [self setBackgroundImage:tokenBackgroundHighlightedImage() forState:UIControlStateHighlighted];
    [self setBackgroundImage:tokenBackgroundHighlightedImage() forState:UIControlStateSelected];
    [self setBackgroundImage:tokenBackgroundHighlightedImage() forState:UIControlStateHighlighted | UIControlStateSelected];
    
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:nil forState:UIControlStateNormal];
    
    UIColor *highlightedTextColor = [UIColor whiteColor];
    
    [self setTitleColor:highlightedTextColor forState:UIControlStateHighlighted];
    [self setTitleColor:highlightedTextColor forState:UIControlStateSelected];
    [self setTitleColor:highlightedTextColor forState:UIControlStateHighlighted | UIControlStateSelected];
    
    [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchDown];
}

#pragma mark - Actions

- (void)buttonPressed {
    
    [self becomeFirstResponder];
}

#pragma mark - Setters

- (void)setLabel:(NSString *)label {
    
    if (![_label isEqualToString:label]) {
        
        _label = label;
        
        [self setTitle:label forState:UIControlStateNormal];
        
        self.preferredWidth = [label sizeWithAttributes:@{NSFontAttributeName : self.titleLabel.font}].width + 10;
    }
}

#pragma mark - Getters

- (CGFloat)preferredWidth {
    
    return MAX(_preferredWidth, 10);
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder {
    
    return YES;
}

- (BOOL)becomeFirstResponder {
    
    if ([super becomeFirstResponder]) {
        
        self.selected = YES;
        
        [self.delegate tagViewDidBecomeFirstResponder:self];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)resignFirstResponder {
    
    if ([super resignFirstResponder]) {
        
        self.selected = NO;
        
        [self.delegate tagViewDidResignFirstResponder:self];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - UIKeyInput

- (void)deleteBackward {
    
    [self.delegate tagViewDidDeleteBackwards:self];
}

- (BOOL)hasText {
    
    return NO;
}

- (void)__unused insertText:(NSString *)__unused text {
    
}

@end
