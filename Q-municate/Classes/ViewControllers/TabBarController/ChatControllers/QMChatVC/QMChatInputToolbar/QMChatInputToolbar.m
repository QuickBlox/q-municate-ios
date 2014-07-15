//
//  QMChatInputToolbar.m
//  Qmunicate
//
//  Created by Andrey on 20.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatInputToolbar.h"
#import "QMChatToolbarContentView.h"
#import "QMChatButtonsFactory.h"
#import "QMChatInputTextView.h"
#import "Parus.h"

const CGFloat kQMChatInputToolbarHeightDefault = 44.0f;

static void * kQMInputToolbarKeyValueObservingContext = &kQMInputToolbarKeyValueObservingContext;

@interface QMChatInputToolbar()

@end

@implementation QMChatInputToolbar

- (void)dealloc {
    [self removeObservers];
    _contentView = nil;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self configureChatToolbarContentView];
        
    }
    
    return self;
}

- (void)configureChatToolbarContentView {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    QMChatToolbarContentView *contentView = [[QMChatToolbarContentView alloc] init];
    [self addSubview:contentView];
    
    [self addConstraints:PVGroup(@[
                                   PVTopOf(contentView).equalTo.topOf(self).asConstraint,
                                   PVLeftOf(contentView).equalTo.leftOf(self).asConstraint,
                                   PVBottomOf(contentView).equalTo.bottomOf(self).asConstraint,
                                   PVRightOf(contentView).equalTo.rightOf(self).asConstraint,
                                   ]).asArray];
    
    [self setNeedsUpdateConstraints];
    
    _contentView = contentView;
    
     [self addObservers];
    
    [self toggleSendButtonEnabled];
}

#pragma mark - Actions

- (void)leftBarButtonPressed:(UIButton *)sender {
    
    [self.delegate chatInputToolbar:self didPressLeftBarButton:sender];
}

- (void)rightBarButtonPressed:(UIButton *)sender {
    
    [self.delegate chatInputToolbar:self didPressRightBarButton:sender];
}

#pragma mark - Input toolbar

- (void)toggleSendButtonEnabled {
    
    BOOL hasText = [self.contentView.textView hasText];
    
    if (self.sendButtonOnRight) {
        self.contentView.rightBarButtonItem.enabled = hasText;
    }
    else {
        self.contentView.leftBarButtonItem.enabled = hasText;
    }
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kQMInputToolbarKeyValueObservingContext) {
        if (object == self.contentView) {
            
            if ([keyPath isEqualToString:NSStringFromSelector(@selector(leftBarButtonItem))]) {
                
                [self.contentView.leftBarButtonItem removeTarget:self
                                                          action:NULL
                                                forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentView.leftBarButtonItem addTarget:self
                                                       action:@selector(leftBarButtonPressed:)
                                             forControlEvents:UIControlEventTouchUpInside];
            }
            else if ([keyPath isEqualToString:NSStringFromSelector(@selector(rightBarButtonItem))]) {
                
                [self.contentView.rightBarButtonItem removeTarget:self
                                                           action:NULL
                                                 forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentView.rightBarButtonItem addTarget:self
                                                        action:@selector(rightBarButtonPressed:)
                                              forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (void)addObservers {
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                          options:0
                          context:kQMInputToolbarKeyValueObservingContext];
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                          options:0
                          context:kQMInputToolbarKeyValueObservingContext];
}

- (void)removeObservers {
    
    @try {
        [self.contentView removeObserver:self
                              forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                                 context:kQMInputToolbarKeyValueObservingContext];
        
        [self.contentView removeObserver:self
                              forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                                 context:kQMInputToolbarKeyValueObservingContext];
        
    } @catch (NSException *__unused exception) {
        NSLog(@"%@", exception);
    }
}

@end
