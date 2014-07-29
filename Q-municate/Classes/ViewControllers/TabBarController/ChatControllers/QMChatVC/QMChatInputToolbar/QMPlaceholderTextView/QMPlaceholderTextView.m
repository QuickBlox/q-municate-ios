//
//  QMChatInputTextView.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 20.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMPlaceholderTextView.h"

typedef NS_ENUM(NSUInteger, QMPlaceholderTextViewStyle) {
    QMPlaceholderTextViewStylePlain,
    QMPlaceholderTextViewStyleBordered,
};

@implementation QMPlaceholderTextView

const CGFloat kChatInputCornerRadius = 6.0;

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self configureTextViewWithStyle:QMPlaceholderTextViewStyleBordered];
    }
    return self;
}

- (void)awakeFromNib
{
    [self configureTextViewWithStyle:QMPlaceholderTextViewStylePlain];
}

- (void)configureTextViewWithStyle:(QMPlaceholderTextViewStyle)textViewStyle {
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if (textViewStyle == QMPlaceholderTextViewStyleBordered) {
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.cornerRadius = kChatInputCornerRadius;
    }
    self.backgroundColor = [UIColor whiteColor];
    
    self.scrollIndicatorInsets = UIEdgeInsetsMake(kChatInputCornerRadius, 0.0f, kChatInputCornerRadius, 0.0f);
    
    self.textContainerInset = UIEdgeInsetsMake(4.0f, 2.0f, 4.0f, 2.0f);
    self.contentInset = UIEdgeInsetsMake(2.0f, 0.0f, 2.0f, 0.0f);
    
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    
    self.font = [UIFont systemFontOfSize:16.0f];
    self.textColor = [UIColor blackColor];
    self.textAlignment = NSTextAlignmentLeft;
    
    self.contentMode = UIViewContentModeRedraw;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    
    self.text = nil;
    
    self.placeHolder = nil;
    self.placeHolderTextColor = [UIColor lightGrayColor];
    
    [self addTextViewNotificationObservers];
}


- (void)dealloc
{
    [self removeTextViewNotificationObservers];
    self.placeHolder = nil;
    self.placeHolderTextColor = nil;
}

#pragma mark - Setters

- (void)setPlaceHolder:(NSString *)placeHolder {
    
    if ([placeHolder isEqualToString:_placeHolder]) {
        return;
    }
    
    _placeHolder = [placeHolder copy];
    [self setNeedsDisplay];
}

- (void)setPlaceHolderTextColor:(UIColor *)placeHolderTextColor {
    
    if ([placeHolderTextColor isEqual:_placeHolderTextColor]) {
        return;
    }
    
    _placeHolderTextColor = placeHolderTextColor;
    [self setNeedsDisplay];
}

#pragma mark - UITextView overrides

- (void)setText:(NSString *)text {
    
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
    
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    if ([self.text length] == 0 && self.placeHolder) {
        [self.placeHolderTextColor set];
        
        [self.placeHolder drawInRect:CGRectInset(rect, 7.0f, 5.0f)
                      withAttributes:[self placeholderTextAttributes]];
    }
}

#pragma mark - Notifications

- (void)addTextViewNotificationObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
}

- (void)removeTextViewNotificationObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:self];
}

- (void)didReceiveTextViewNotification:(NSNotification *)notification {
    
    [self setNeedsDisplay];
}

#pragma mark - Placeholder text attributes

- (NSDictionary *)placeholderTextAttributes {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = self.textAlignment;
    
    return @{
             NSFontAttributeName : self.font,
             NSForegroundColorAttributeName : self.placeHolderTextColor,
             NSParagraphStyleAttributeName : paragraphStyle
             };
}

@end
