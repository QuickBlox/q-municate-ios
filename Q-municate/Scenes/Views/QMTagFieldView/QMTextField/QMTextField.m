//
//  QMTextField.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTextField.h"

#import "QMHelpers.h"

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
    
    self.textAlignment = NSTextAlignmentLeft;
}

#pragma mark - Methods

- (void)setShowPlaceholder:(BOOL)showPlaceholder animated:(BOOL)animated {
    
    if (showPlaceholder != self.placeholderLabel.alpha > FLT_EPSILON) {
        
        if (animated) {
            
            @weakify(self);
            [UIView animateWithDuration:kQMBaseAnimationDuration animations:^{
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
    
    [self.delegate textFieldWillDeleteBackwards:self];
    
    if (iosMajorVersion() > 8) {
        
        [super deleteBackward];
    }
}

- (BOOL)keyboardInputShouldDelete:(UITextField *)textField {
    
    BOOL shouldDelete = YES;
    
    if ([UITextField instancesRespondToSelector:_cmd]) {
        
        BOOL wasEmpty = self.text.length == 0;
        
        BOOL (*keyboardInputShouldDelete)(id, SEL, UITextField *) = (BOOL (*)(id, SEL, UITextField *))[UITextField instanceMethodForSelector:_cmd];
        
        if (keyboardInputShouldDelete) {
            
            shouldDelete = keyboardInputShouldDelete(self, _cmd, textField);
        }
        
        if (wasEmpty) {
            
            shouldDelete = NO;
        }
        
        if (iosMajorVersion() >= 8 && wasEmpty) {
            
            [self deleteBackward];
        }
    }
    
    return shouldDelete;
}

#pragma mark - UIResponder

- (BOOL)becomeFirstResponder {
    
    if ([super becomeFirstResponder]) {
        
        [self.delegate textFieldDidBecomeFirstResponder:self];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)resignFirstResponder {
    
    if ([super resignFirstResponder]) {
        
        [self.delegate textFieldDidResignFirstResponder:self];
        
        return YES;
    }
    
    return NO;
}

@end
