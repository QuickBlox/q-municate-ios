//
//  QMTextField.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTextField.h"

@implementation QMTextField

@dynamic delegate;

#pragma mark - Construction

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    _placeholderLabel = [[UILabel alloc] init];
    _placeholderLabel.textAlignment = NSTextAlignmentLeft;
    _placeholderLabel.backgroundColor = [UIColor clearColor];
    _placeholderLabel.font = [UIFont systemFontOfSize:15];
    [_placeholderLabel sizeToFit];
    _placeholderLabel.userInteractionEnabled = NO;
    _placeholderLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
    
    [self setTextAlignment:NSTextAlignmentLeft];
}

#pragma mark - Methods

- (void)setShowPlaceholder:(BOOL)showPlaceholder animated:(BOOL)animated {
    
    if (showPlaceholder != self.placeholderLabel.alpha > FLT_EPSILON) {
        
        if (animated) {
            
            @weakify(self);
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                 self.placeholderLabel.alpha = showPlaceholder ? 1.0f : 0.0f;
             }];
        }
        else {
            
            self.placeholderLabel.alpha = showPlaceholder ? 1.0f : 0.0f;
        }
    }
}

#pragma mark - Setters

- (void)setText:(NSString *)text {
    [super setText:text];
    
    self.placeholderLabel.hidden = text.length != 0;
}

#pragma mark - UIKeyInput

- (void)deleteBackward {
    [super deleteBackward];
    
    if ([self.delegate respondsToSelector:@selector(textFieldDidPressBackspace:)]) {
        
        [self.delegate textFieldDidPressBackspace:self];
    }
}

#pragma mark - UIResponder

- (BOOL)becomeFirstResponder {
    
    if ([super becomeFirstResponder]) {
        
        if ([self.delegate respondsToSelector:@selector(textFieldDidBecomeFirstResponder:)]) {
            
            [self.delegate textFieldDidBecomeFirstResponder:self];
        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL)resignFirstResponder {
    
    if ([super resignFirstResponder]) {
        
        if ([self.delegate respondsToSelector:@selector(textFieldDidResignFirstResponder:)]) {
            
            [self.delegate textFieldDidResignFirstResponder:self];
        }
        
        return YES;
    }
    
    return NO;
}

@end
