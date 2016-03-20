//
//  QMTagView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "QMTagFieldView.h"
#import "QMTagView.h"
#import "QMTextField.h"

@interface QMTagFieldScrollView : UIScrollView

@end

@implementation QMTagFieldScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)__unused view {
    
    return YES;
}

@end

@interface QMTagFieldView () <QMTextFieldDelegate>

@property (strong, nonatomic) NSMutableDictionary *tagAnimations;
@property (strong, nonatomic) NSMutableArray *tagsList;
@property (strong, nonatomic) QMTextField *textField;
@property (strong, nonatomic) UIView *shadowView;
@property (assign, nonatomic) BOOL wasEmpty;

@end

@implementation QMTagFieldView

#pragma mark - Constructors

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configure];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    _lineHeight = 26;
    _linePadding = 9;
    _lineSpacing = 11;
    _maxNumberOfLines = 2;
    
    _currentNumberOfLines = 1;
    
    _shadowView = [[UIView alloc] init];
    _shadowView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 0);
    _shadowView.layer.zPosition = 1;
    [self addSubview:_shadowView];
    
    self.clipsToBounds = NO;
    self.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [[QMTagFieldScrollView alloc] initWithFrame:self.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.delaysContentTouches = YES;
    _scrollView.canCancelContentTouches = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.opaque = YES;
    [self addSubview:_scrollView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [_scrollView addGestureRecognizer:tapRecognizer];
    
    _textField = [[QMTextField alloc] initWithFrame:CGRectMake(0, 0, 10, 42)];
    _textField.text = @"";
    _textField.delegate = self;
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.font = [UIFont systemFontOfSize:15];
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_scrollView addSubview:_textField];
    
    _textField.placeholderLabel.text = _placeholder;
    [_textField.placeholderLabel sizeToFit];
    _textField.placeholderLabel.frame = CGRectOffset(_textField.placeholderLabel.frame, 9 + 5, 9 + 4);
    [_scrollView addSubview:_textField.placeholderLabel];
    
    _tagsList = [NSMutableArray array];
}

#pragma mark - Overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self doLayout:self.tagAnimations != nil];
    
    if (self.tagAnimations != nil) {
        
        NSArray *enumerateTagsList = self.tagsList.copy;
        for (QMTagView *tagView in enumerateTagsList) {
            
            if (tagView.tagID == nil) {
                
                continue;
            }
            
            NSNumber *nAnimation = [self.tagAnimations objectForKey:tagView.tagID];
            if (nAnimation != nil) {
                
                tagView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                tagView.alpha = 0.0f;
            }
        }
        
        @weakify(self);
        [UIView animateWithDuration:kQMBaseAnimationDuration animations:^{
            @strongify(self);
            
            for (QMTagView *tagView in enumerateTagsList) {
                
                if (tagView.tagID == nil) {
                    
                    continue;
                }
                
                NSNumber *nAnimation = [self.tagAnimations objectForKey:tagView.tagID];
                if (nAnimation != nil) {
                    
                    tagView.transform = CGAffineTransformIdentity;
                    tagView.alpha = 1.0f;
                }
            }
        }];
        
        self.tagAnimations = nil;
    }
}

#pragma mark - Setters

- (void)setPlaceholder:(NSString *)placeholder {
    
    _placeholder = placeholder;
    _textField.placeholderLabel.text = _placeholder;
    [_textField.placeholderLabel sizeToFit];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.shadowView.frame = CGRectMake(0.0f, frame.size.height, frame.size.width, 0.0f);
}

#pragma mark - Getters

- (BOOL)hasFirstResponder {
    
    return self.textField.isFirstResponder;
}

- (BOOL)searchIsActive {
    
    return self.textField.text.length != 0;
}

#pragma mark - Methods

- (void)addTag:(NSString *)title tagID:(id)tagID animated:(BOOL)animated {
    
    QMTagView *tagView = [[QMTagView alloc] initWithFrame:CGRectMake(0, 0, 20, 28)];
    tagView.label = title;
    tagView.tagID = tagID;
    
    [self.tagsList addObject:tagView];
    [self.scrollView addSubview:tagView];
    
    if (animated) {
        
        if (self.tagAnimations == nil) {
            
            self.tagAnimations = [NSMutableDictionary dictionary];
        }
        
        if (tagID != nil) {
            
            [self.tagAnimations setObject:@1 forKey:tagID];
        }
    }
    
    [self.textField setShowPlaceholder:NO animated:self.textField.text.length == 0];
    
    [self setNeedsLayout];
}

- (NSArray *)tagIDs {
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.tagsList.count];
    
    NSArray *enumerateTagsList = self.tagsList.copy;
    for (QMTagView *tagView in enumerateTagsList) {
        
        if (tagView.tagID != nil) {
            
            [array addObject:tagView.tagID];
        }
    }
    
    return array;
}

- (void)removeTagsAtIndexes:(NSIndexSet *)indexSet {
    
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, __unused BOOL *stop) {
        
        QMTagView *tagView = [self.tagsList objectAtIndex:index];
        if ([tagView isFirstResponder]) {
            
            [tagView resignFirstResponder];
        }
        
        [UIView animateWithDuration:kQMBaseAnimationDuration animations:^{
            
            tagView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            tagView.alpha = 0.0f;
            
        } completion:^(__unused BOOL finished) {
            
            [tagView removeFromSuperview];
        }];
    }];
    
    [self.tagsList removeObjectsAtIndexes:indexSet];
    
    if (self.tagAnimations == nil) {
        
        self.tagAnimations = [NSMutableDictionary dictionary];
    }
    
    [self setNeedsLayout];
    
    if (self.tagsList.count == 0 && self.textField.text.length == 0) {
        
        [self.textField setShowPlaceholder:YES animated:YES];
    }
}

- (void)removeTagWithID:(id)tagID {
    
    for (NSUInteger i = 0; i < self.tagsList.count; ++i) {
        
        QMTagView *tagView = self.tagsList[i];
        if ([tagView.tagID isEqual:tagID]) {
            
            [self removeTagsAtIndexes:[NSIndexSet indexSetWithIndex:i]];
            break;
        }
    }
}

- (void)clearText {
    
    self.textField.text = @"";
    
    if ([self.delegate respondsToSelector:@selector(tagFieldView:didChangeSearchStatus:byClearingTextField:)]) {
        
        [self.delegate tagFieldView:self didChangeSearchStatus:[self searchIsActive] byClearingTextField:NO];
    }
}

- (void)beginTransition:(NSTimeInterval)duration {
    
    UIImage *inputFieldImage = nil;
    UIImageView *temporaryImageView = nil;
    
    UIGraphicsBeginImageContextWithOptions(self.scrollView.bounds.size, YES, 0.0f);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    inputFieldImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    temporaryImageView = [[UIImageView alloc] initWithImage:inputFieldImage];
    temporaryImageView.frame = _scrollView.bounds;
    
    UIView *temporaryImageViewContainer = [[UIView alloc] initWithFrame:self.scrollView.frame];
    temporaryImageViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    temporaryImageViewContainer.clipsToBounds = YES;
    [temporaryImageViewContainer addSubview:temporaryImageView];
    
    [self insertSubview:temporaryImageViewContainer aboveSubview:self.scrollView];
    self.scrollView.alpha = 0.0f;
    
    @weakify(self);
    [UIView animateWithDuration:duration animations:^{
        @strongify(self);
        temporaryImageView.alpha = 0.0f;
        self.scrollView.alpha = 1.0f;
        
    } completion:^(__unused BOOL finished) {
        
        [temporaryImageView removeFromSuperview];
        [temporaryImageViewContainer removeFromSuperview];
    }];
}

- (CGFloat)preferredHeight {
    
    NSInteger visibleNumberOfLines = MIN(MAX(1, self.currentNumberOfLines), self.maxNumberOfLines);
    return self.lineHeight * visibleNumberOfLines + MAX(0, visibleNumberOfLines - 1) * self.lineSpacing + self.linePadding * 2;
}

- (void)doLayout:(BOOL)animated {
    
    CGFloat width = self.frame.size.width;
    
    const CGFloat textFieldMinWidth = 60;
    const CGFloat padding = 9;
    const CGFloat textFieldPadding = 5;
    const CGFloat spacing = 1;
    
    NSInteger currentLine = 0;
    CGFloat currentX = padding;
    CGFloat currentY = self.linePadding;
    
    CGFloat additionalPadding = 0;
    
    CGRect targetFrames[self.tagsList.count];
    memset(targetFrames, 0, sizeof(CGRect) * self.tagsList.count);
    
    NSInteger index = -1;
    
    NSArray *enumerateTagsList = self.tagsList.copy;
    for (QMTagView *tagView in enumerateTagsList) {
        index++;
        
        CGFloat tokenWidth = [tagView preferredWidth];
        
        if (width - padding - currentX - additionalPadding < MAX(tokenWidth, textFieldMinWidth) && currentX > padding + FLT_EPSILON) {
            
            currentLine++;
            currentY += self.lineHeight + self.lineSpacing;
            currentX = padding;
        }
        
        CGRect tokenFrame = CGRectMake(currentX, currentY - 1, MIN(tokenWidth, width - padding - currentX - additionalPadding), tagView.frame.size.height);
        
        if (animated && tagView.frame.origin.x > FLT_EPSILON) {
            
            targetFrames[index] = tokenFrame;
        }
        else {
            
            tagView.frame = tokenFrame;
        }
        
        currentX += tokenFrame.size.width + spacing;
    }
    
    BOOL lastLineContainsTextFieldOnly = NO;
    
    if (width - padding - currentX - additionalPadding < textFieldMinWidth) {
        
        currentLine++;
        currentY += self.lineHeight + self.lineSpacing;
        currentX = padding;
        
        lastLineContainsTextFieldOnly = YES;
    }
    
    if (currentLine + 1 != self.currentNumberOfLines) {
        
        animated = YES;
    }
    
    CGRect textFieldFrame = CGRectMake(currentX + textFieldPadding, currentY + 4 - 12, width - padding - currentX - textFieldPadding * 2 - additionalPadding + 4, self.textField.frame.size.height);
    self.textField.frame = textFieldFrame;
    if (animated) {
        
        self.textField.alpha = 0.0f;
        
        @weakify(self);
        [UIView animateWithDuration:kQMBaseAnimationDuration animations:^{
            @strongify(self);
            self.textField.alpha = 1.0f;
        }];
    }
    
    if (lastLineContainsTextFieldOnly && ![self hasFirstResponder]) {
        
        currentLine--;
        currentY -= self.lineHeight + self.lineSpacing;
    }
    
    if (animated) {
        
        [UIView beginAnimations:@"tagField" context:nil];
        [UIView setAnimationDuration:0.15f];
        
        index = -1;
        for (QMTagView *tagView in enumerateTagsList) {
            index++;
            
            if (targetFrames[index].origin.x > FLT_EPSILON) {
                
                tagView.frame = targetFrames[index];
            }
        }
    }
    
    currentY += self.lineHeight + self.linePadding;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, currentY);
    
    if (animated) {
        
        [UIView commitAnimations];
    }
    
    if (MIN(currentLine + 1, self.maxNumberOfLines) != MIN(self.currentNumberOfLines, self.maxNumberOfLines)) {
        
        if ([self.delegate respondsToSelector:@selector(tagFieldView:didChangeHeight:)]) {
            
            [self.delegate tagFieldView:self didChangeHeight:_lineHeight * MIN(currentLine + 1, _maxNumberOfLines) + MAX(0, currentLine) * _lineSpacing + _linePadding * 2];
        }
    }
    else if (currentLine + 1 > self.currentNumberOfLines) {
        
        [self scrollToTextField:YES];
    }
    
    self.currentNumberOfLines = currentLine + 1;
}

- (void)scrollToTextField:(BOOL)animated {
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGSize contentSize = self.scrollView.contentSize;
    CGSize frameSize = self.scrollView.frame.size;
    
    if (contentOffset.y < contentSize.height - frameSize.height) {
        
        contentOffset = CGPointMake(0, contentSize.height - frameSize.height);
    }
    
    if (contentOffset.y < 0) {
        
        contentOffset.y = 0;
    }
    
    if (!animated) {
        
        [self.scrollView setContentOffset:contentOffset animated:animated];
    }
    else {
        
        @weakify(self);
        [UIView animateWithDuration:kQMBaseAnimationDuration animations:^{
            @strongify(self);
            [self.scrollView setContentOffset:contentOffset animated:NO];
        }];
    }
}

#pragma mark - External UI actions

- (void)highlightTag:(QMTagView *)tagView {
    
    NSArray *enumerateTagsList = self.tagsList.copy;
    for (QMTagView *view in enumerateTagsList) {
        
        if (view != tagView &&
            view.selected) {
            
            view.selected = NO;
        }
    }
    
    tagView.selected = YES;
    
    [self setNeedsLayout];
}

- (void)unhighlightTag:(QMTagView *)tagView {
    
    tagView.selected = NO;
    
    if (self.tagAnimations == nil) {
        
        self.tagAnimations = [NSMutableDictionary dictionary];
    }
    
    [self setNeedsLayout];
}

- (void)deleteTag:(QMTagView *)tagView {
    
    NSInteger index = -1;
    NSArray *enumerateTagsList = self.tagsList.copy;
    for (QMTagView *view in enumerateTagsList) {
        index++;
        
        if (view == tagView)
        {
            [self.tagsList removeObjectAtIndex:index];
            break;
        }
    }
    
    [tagView removeFromSuperview];
    [self.textField becomeFirstResponder];
    
    [self setNeedsLayout];
    
    if ([self.delegate respondsToSelector:@selector(tagFieldView:didDeleteTagWithID:)]) {
        
        [self.delegate tagFieldView:self didDeleteTagWithID:tagView.tagID];
    }
    
    if (self.tagsList.count == 0) {
        
        [self.textField setShowPlaceholder:YES animated:NO];
    }
}

#pragma mark - QMTextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _textField) {
        
        BOOL wasEmpty = textField.text.length == 0;
        textField.text = @"";
        
        if (self.tagsList.count == 0) {
            
            [self.textField setShowPlaceholder:YES animated:YES];
        }
        
        if ([self.delegate respondsToSelector:@selector(tagFieldView:didChangeText:)]) {
            
            [self.delegate tagFieldView:self didChangeText:textField.text];
        }
        
        if (wasEmpty != textField.text.length == 0 &&
            [self.delegate respondsToSelector:@selector(tagFieldView:didChangeSearchStatus:byClearingTextField:)]) {
            
            [self.delegate tagFieldView:self didChangeSearchStatus:[self searchIsActive] byClearingTextField:YES];
        }
        
        [self scrollToTextField:NO];
        
        self.textField.hidden = YES;
        
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.textField.hidden = NO;
        });
    }
    
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    [self scrollToTextField:YES];
    
    if ([self.delegate respondsToSelector:@selector(tagFieldView:didChangeText:)]) {
        
        [self.delegate tagFieldView:self didChangeText:textField.text];
    }
    
    if (self.wasEmpty != textField.text.length == 0 &&
        [self.delegate respondsToSelector:@selector(tagFieldView:didChangeSearchStatus:byClearingTextField:)]) {
        
        [self.delegate tagFieldView:self didChangeSearchStatus:[self searchIsActive] byClearingTextField:YES];
    }
    
    if (self.tagsList.count == 0) {
        
        BOOL isEmpty = textField.text.length == 0;
        
        [self.textField setShowPlaceholder:isEmpty animated:isEmpty];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)__unused range replacementString:(NSString *)__unused string {
    
    if (textField == _textField) {
        
        self.wasEmpty = textField.text.length == 0;
    }
    
    return YES;
}

- (void)textFieldDidPressBackspace:(QMTextField *)textField {
    
    if (self.tagsList.count != 0 && textField.text.length == 0) {
        
        [[self.tagsList lastObject] becomeFirstResponder];
    }
}

- (void)textFieldDidBecomeFirstResponder:(QMTextField *)__unused textField {
    
    [self setNeedsLayout];
}

- (void)textFieldDidResignFirstResponder:(QMTextField *)__unused textField {
    
    if (self.tagAnimations == nil) {
        
        self.tagAnimations = [NSMutableDictionary dictionary];
    }
    
    [self setNeedsLayout];
}

#pragma mark - Tap gestures

- (void)tapRecognized:(UITapGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        
        [self.textField becomeFirstResponder];
    }
}

@end
