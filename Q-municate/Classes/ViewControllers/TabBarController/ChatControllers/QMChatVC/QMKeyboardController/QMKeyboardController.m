//
//  QMKeyboardController.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 23.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMKeyboardController.h"
#import "QMHelpers.h"

NSString * const QMKeyboardControllerNotificationKeyboardDidChangeFrame = @"QMKeyboardControllerNotificationKeyboardDidChangeFrame";
NSString * const QMKeyboardControllerUserInfoKeyKeyboardDidChangeFrame = @"QMKeyboardControllerUserInfoKeyKeyboardDidChangeFrame";

static void * kQMKeyboardControllerKeyValueObservingContext = &kQMKeyboardControllerKeyValueObservingContext;

@interface QMKeyboardController()

@property (weak, nonatomic) UIView *keyboardView;
@property (assign, nonatomic) BOOL subscribed;

@end


@implementation QMKeyboardController

- (instancetype)initWithTextView:(UITextView *)textView
                     contextView:(UIView *)contextView
            panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
                        delegate:(id<QMKeyboardControllerDelegate>)delegate {
    
    NSParameterAssert(textView != nil);
    NSParameterAssert(contextView != nil);
    NSParameterAssert(panGestureRecognizer != nil);
    
    self = [super init];
    if (self) {
        _textView = textView;
        _contextView = contextView;
        _panGestureRecognizer = panGestureRecognizer;
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    
    [self removeKeyboardFrameObserver];
    [self unsubscribeFromKeyboardNotifications];
}

#pragma mark - Setters

- (void)setKeyboardView:(UIView *)keyboardView {
    
    if (_keyboardView) {
        [self removeKeyboardFrameObserver];
    }
    
    _keyboardView = keyboardView;
    
    
    if (keyboardView) {
        self.subscribed = YES;
        [_keyboardView addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(frame))
                           options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                           context:kQMKeyboardControllerKeyValueObservingContext];
    }
}

#pragma mark - Keyboard controller

- (void)beginListeningForKeyboard {
    
    self.textView.inputAccessoryView = [[UIView alloc] init];
    [self subscribeToKeyboardNotifications];
}

- (void)endListeningForKeyboard {
    
    self.textView.inputAccessoryView = nil;
    [self unsubscribeFromKeyboardNotifications];
    [self setKeyboardViewHidden:NO];
    
    self.keyboardView = nil;
}

#pragma mark - Notifications

- (void)subscribeToKeyboardNotifications {
    
    [self unsubscribeFromKeyboardNotifications];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self
                               selector:@selector(didReceiveKeyboardDidShowNotification:)
                                   name:UIKeyboardDidShowNotification
                                 object:nil];
        
        [notificationCenter addObserver:self
                               selector:@selector(didReceiveKeyboardWillChangeFrameNotification:)
                                   name:UIKeyboardWillChangeFrameNotification
                                 object:nil];
        
        [notificationCenter addObserver:self
                               selector:@selector(didReceiveKeyboardDidChangeFrameNotification:)
                                   name:UIKeyboardDidChangeFrameNotification
                                 object:nil];
        
        [notificationCenter addObserver:self
                               selector:@selector(didReceiveKeyboardDidHideNotification:)
                                   name:UIKeyboardDidHideNotification
                                 object:nil];
    });
}

- (void)unsubscribeFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveKeyboardDidShowNotification:(NSNotification *)notification {
    
    self.keyboardView = self.textView.inputAccessoryView.superview;
    [self setKeyboardViewHidden:NO];
    
    __weak __typeof(self)weakSelf = self;
    [self handleKeyboardNotification:notification completion:^(BOOL finished) {
        [weakSelf.panGestureRecognizer addTarget:weakSelf action:@selector(handlePanGestureRecognizer:)];
    }];
}

- (void)didReceiveKeyboardWillChangeFrameNotification:(NSNotification *)notification {
    
    [self handleKeyboardNotification:notification completion:nil];
}

- (void)didReceiveKeyboardDidChangeFrameNotification:(NSNotification *)notification {
    
    [self setKeyboardViewHidden:NO];
    [self handleKeyboardNotification:notification completion:nil];
}

- (void)didReceiveKeyboardDidHideNotification:(NSNotification *)notification {
    
    self.keyboardView = nil;
    __weak __typeof(self)weakSelf = self;
    [self handleKeyboardNotification:notification completion:^(BOOL finished) {
        [weakSelf.panGestureRecognizer removeTarget:weakSelf action:NULL];
    }];
}

- (void)handleKeyboardNotification:(NSNotification *)notification completion:(void(^)(BOOL finished))completion {
    
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }
    
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyboardEndFrameConverted = [self.contextView convertRect:keyboardEndFrame fromView:nil];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurveOption
                     animations:^{
                         [self.delegate keyboardDidChangeFrame:keyboardEndFrameConverted];
                         [self postKeyboardFrameNotificationForFrame:keyboardEndFrameConverted];
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

- (void)setKeyboardViewHidden:(BOOL)hidden {
    
    self.keyboardView.hidden = hidden;
    self.keyboardView.userInteractionEnabled = !hidden;
}

- (void)postKeyboardFrameNotificationForFrame:(CGRect)frame {
    
    NSDictionary *userInfo = @{ QMKeyboardControllerUserInfoKeyKeyboardDidChangeFrame : [NSValue valueWithCGRect:frame] };
    [[NSNotificationCenter defaultCenter] postNotificationName:QMKeyboardControllerNotificationKeyboardDidChangeFrame
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == kQMKeyboardControllerKeyValueObservingContext) {
        
        if (object == self.keyboardView && [keyPath isEqualToString:NSStringFromSelector(@selector(frame))]) {
            
            CGRect oldKeyboardFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
            CGRect newKeyboardFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
            
            if (CGRectEqualToRect(newKeyboardFrame, oldKeyboardFrame) || CGRectIsNull(newKeyboardFrame)) {
                return;
            }
            
            [self.delegate keyboardDidChangeFrame:newKeyboardFrame];
            [self postKeyboardFrameNotificationForFrame:newKeyboardFrame];
        }
    }
}

- (void)removeKeyboardFrameObserver {
    
    if (self.subscribed) {
        @try {
            [_keyboardView removeObserver:self
                               forKeyPath:NSStringFromSelector(@selector(frame))
                                  context:kQMKeyboardControllerKeyValueObservingContext];
            self.subscribed = NO;
        }
        @catch (NSException * __unused exception) { }
    }
}

#pragma mark - Pan gesture recognizer

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)pan {
    
    CGPoint touch = [pan locationInView:self.contextView];
    
    CGFloat contextViewWindowHeight = CGRectGetHeight(self.contextView.window.frame);
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        contextViewWindowHeight = CGRectGetWidth(self.contextView.window.frame);
    }
    
    CGFloat keyboardViewHeight = CGRectGetHeight(self.keyboardView.frame);
    
    CGFloat dragThresholdY = (contextViewWindowHeight - keyboardViewHeight - self.keyboardTriggerPoint.y);
    
    CGRect newKeyboardViewFrame = self.keyboardView.frame;
    
    BOOL userIsDraggingNearThresholdForDismissing = (touch.y > dragThresholdY);
    
    self.keyboardView.userInteractionEnabled = !userIsDraggingNearThresholdForDismissing;
    
    switch (pan.state) {
            
        case UIGestureRecognizerStateChanged: {
            
            newKeyboardViewFrame.origin.y = touch.y + self.keyboardTriggerPoint.y;
            newKeyboardViewFrame.origin.y = MIN(newKeyboardViewFrame.origin.y, contextViewWindowHeight);
            newKeyboardViewFrame.origin.y = MAX(newKeyboardViewFrame.origin.y, contextViewWindowHeight - keyboardViewHeight);
            
            if (FloatAlmostEqual(CGRectGetMinY(newKeyboardViewFrame), CGRectGetMinY(self.keyboardView.frame), 0.00001)) {
                return;
            }
            
            self.keyboardView.frame = newKeyboardViewFrame;
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            
            BOOL keyboardViewIsHidden = (CGRectGetMinY(self.keyboardView.frame) >= contextViewWindowHeight);
            if (keyboardViewIsHidden) {
                [self shouldHide];
                return;
            }
            
            CGPoint velocity = [pan velocityInView:self.contextView];
            BOOL userIsScrollingDown = (velocity.y > 0.0f);
            BOOL shouldHide = (userIsScrollingDown && userIsDraggingNearThresholdForDismissing);
            
            newKeyboardViewFrame.origin.y = shouldHide ? contextViewWindowHeight : (contextViewWindowHeight - keyboardViewHeight);
            
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseOut animations:^ {
                self.keyboardView.frame = newKeyboardViewFrame;
            } completion:^(BOOL finished) {
                self.keyboardView.userInteractionEnabled = !shouldHide;
                if (shouldHide) {
                    [self shouldHide];
                }
            }];
        }
            break;
            
        default:break;
    }
}

- (void)shouldHide {
    
    [self setKeyboardViewHidden:YES];
    [self removeKeyboardFrameObserver];
    [self.textView resignFirstResponder];
}

@end