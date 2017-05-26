//
//  QMInputToolbar.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMInputToolbar.h"
#import "UIView+QM.h"
#import "QMToolbarContentView.h"
#import "QMChatResources.h"
#import "QMAudioRecordButton.h"
#import "UIImage+QM.h"
#import "QMAudioRecordView.h"


static void * kQMInputToolbarKeyValueObservingContext = &kQMInputToolbarKeyValueObservingContext;

@interface QMInputToolbar() <QMAudioRecordButtonProtocol, QMAudioRecordViewProtocol>

@property (assign, nonatomic) BOOL isObserving;

@property (assign, nonatomic, getter=isRecording) BOOL recording;

@property (weak, nonatomic) QMAudioRecordView *audioRecordView;

@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) QMAudioRecordButton *audioRecordButtonItem;

@end

@implementation QMInputToolbar
@dynamic delegate;

#pragma mark - Initialization

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self commonInit];
    
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.isObserving = NO;
    self.sendButtonOnRight = YES;
    
    self.preferredDefaultHeight = 44.0f;
    
    QMToolbarContentView *toolbarContentView = [self loadToolbarContentView];
    
    [self addSubview:toolbarContentView];
    [self pinAllEdgesOfSubview:toolbarContentView];
    [self setNeedsUpdateConstraints];
    
    _contentView = toolbarContentView;
    
    [self addObservers];
    
    [self toggleSendButtonEnabled];
}


- (QMToolbarContentView *)loadToolbarContentView {
    
    NSArray *nibViews = [[QMChatResources resourceBundle] loadNibNamed:NSStringFromClass([QMToolbarContentView class])
                                                                 owner:nil
                                                               options:nil];
    return nibViews.firstObject;
}

- (void)dealloc {
    
    [self removeObservers];
    _contentView = nil;
    _audioRecordView = nil;
}

#pragma mark - Setters

- (void)setPreferredDefaultHeight:(CGFloat)preferredDefaultHeight {
    
    NSParameterAssert(preferredDefaultHeight > 0.0f);
    _preferredDefaultHeight = preferredDefaultHeight;
}

#pragma mark - Actions

- (void)leftBarButtonPressed:(UIButton *)sender {
    
    [self.delegate messagesInputToolbar:self didPressLeftBarButton:sender];
}

- (void)rightBarButtonPressed:(UIButton *)sender {
    
    [self.delegate messagesInputToolbar:self didPressRightBarButton:sender];
}

#pragma mark - Input toolbar

- (void)toggleButtons {
    
    BOOL hasText = [self.contentView.textView hasText];
    BOOL hasTextAttachment = [self.contentView.textView hasTextAttachment];
    
    if (self.sendButtonOnRight) {
        
        if (hasText || hasTextAttachment) {
            
            self.contentView.rightBarButtonItem.hidden = NO;
            
            if (!self.audioRecordButtonItem.superview) {
                [self.contentView.rightBarButtonContainerView addSubview:[self audioRecordButtonItem]];
            }
            self.audioRecordButtonItem.hidden = YES;
            
        }
        else {
            
            self.contentView.rightBarButtonItem.hidden = YES;
            
            if (!self.audioRecordButtonItem.superview) {
                [self.contentView.rightBarButtonContainerView addSubview:[self audioRecordButtonItem]];
            }
            self.audioRecordButtonItem.hidden = NO;
        }
        
    }
    else {
        
        self.contentView.leftBarButtonItem.hidden = !(hasText || hasTextAttachment);
    }
}

- (void)toggleSendButtonEnabled {
    
    if (self.audioRecordingIsEnabled) {
        [self toggleButtons];
        return;
    }
    
    BOOL hasText = [self.contentView.textView hasText];
    BOOL hasTextAttachment = [self.contentView.textView hasTextAttachment];
    
    if (self.sendButtonOnRight) {
        
        self.contentView.rightBarButtonItem.enabled = hasText || hasTextAttachment;
        
    }
    else {
        
        self.contentView.leftBarButtonItem.hidden = !(hasText || hasTextAttachment);
    }
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
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
            
            [self toggleSendButtonEnabled];
        }
    }
}

- (void)addObservers {
    
    if (self.isObserving) {
        return;
    }
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                          options:0
                          context:kQMInputToolbarKeyValueObservingContext];
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                          options:0
                          context:kQMInputToolbarKeyValueObservingContext];
    
    self.isObserving = YES;
}

- (void)removeObservers {
    
    if (!self.isObserving) {
        return;
    }
    
    @try {
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                             context:kQMInputToolbarKeyValueObservingContext];
        
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                             context:kQMInputToolbarKeyValueObservingContext];
    }
    @catch (NSException *__unused exception) { }
    
    self.isObserving = NO;
}


- (void)setShowRecordingInterface:(BOOL)show velocity:(CGFloat)velocity
{
    if (show) {
        
        [self.audioRecordButtonItem animateIn];
        
        if (_audioRecordView == nil)
        {
            QMAudioRecordView *recordView = [QMAudioRecordView loadAudioRecordView];
            recordView.clipsToBounds = true;
            recordView.delegate = self;
            [self insertSubview:recordView aboveSubview:self.contentView];
            [self pinAllEdgesOfSubview:recordView];
            [self setNeedsUpdateConstraints];
            
            _audioRecordView = recordView;
        }
        
        [self.audioRecordView setShowRecordingInterface:show
                                               velocity:velocity];
        
        
        [UIView animateWithDuration:0.26 delay:0.0 options:0 animations:^
         {
             self.contentView.alpha = 0.0f;
         } completion:nil];
        
    }
    else
    {
        [self.audioRecordButtonItem animateOut];
        
        int options = 0;
        
        [self.audioRecordView setShowRecordingInterface:show velocity:velocity];
        [self.audioRecordView removeFromSuperview];
        self.audioRecordView = nil;
        [UIView animateWithDuration:0.25 delay:0.0 options:options animations:^
         {
             self.contentView.alpha = 1.0f;
         } completion:nil];
    }
    
}


//MARK: QMAudioRecordButtonProtocol

- (void)audioRecordingStarted {
    
    [self.audioRecordView audioRecordingStarted];
}

- (void)audioRecordingFinished {
    
    [self.audioRecordView audioRecordingFinished];
    [self setShowRecordingInterface:false velocity:0.0];
}

- (void)recordButtonInteractionDidBegin {
    
    if ([self.delegate respondsToSelector:@selector(messagesInputToolbarAudioRecordingEnabled:)])
    {
        
        if ([self.delegate messagesInputToolbarAudioRecordingEnabled:self]) {
            
            if ([self.delegate respondsToSelector:@selector(messagesInputToolbarAudioRecordingStart:)]) {
                
                self.recording = true;
                [self setShowRecordingInterface:true velocity:0.0f];
                
                [self.delegate messagesInputToolbarAudioRecordingStart:self];
            }
        }
    }
}

- (void)recordButtonInteractionDidCancel:(CGFloat)velocity {
    
    if (self.isRecording) {
        
        self.recording = NO;
        [self setShowRecordingInterface:false velocity:velocity];
        
        if ([self.delegate respondsToSelector:@selector(messagesInputToolbarAudioRecordingCancel:)]) {
            [self.delegate messagesInputToolbarAudioRecordingCancel:self];
        }
    }
}

- (void)forceFinishRecording {
    
    if (self.isRecording) {
        self.recording = NO;
        
        [self setShowRecordingInterface:false velocity:0.0];
        if ([self.delegate respondsToSelector:@selector(messagesInputToolbarAudioRecordingCancel:)]) {
            [self.delegate messagesInputToolbarAudioRecordingCancel:self];
        }
    }
}
- (void)recordButtonInteractionDidComplete:(CGFloat)velocity {
    
    if (self.isRecording) {
        self.recording = NO;
        [self setShowRecordingInterface:false velocity:velocity];
        if ([self.delegate respondsToSelector:@selector(messagesInputToolbarAudioRecordingComplete:)]) {
            [self.delegate messagesInputToolbarAudioRecordingComplete:self];
        }
    }
}

- (void)recordButtonInteractionDidUpdate:(CGFloat)value {
    [self.audioRecordView updateInterfaceWithVelocity:value];
}

- (void)shakeControls {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.3f;
    animation.values = @[@(-10), @(10), @(-5), @(5), @(0)];
    [self.audioRecordButtonItem.layer addAnimation:animation forKey:@"shake"];
    
}

- (NSTimeInterval)currentDuration {
    
    if ([self.delegate respondsToSelector:@selector(inputPanelAudioRecordingDuration:)]) {
        return [self.delegate inputPanelAudioRecordingDuration:self];
    }
    
    return 0.0;
}

- (QMAudioRecordButton *)audioRecordButtonItem {
    
    if (!_audioRecordButtonItem) {
        
        UIImage *recordImage = [QMChatResources imageNamed:@"MicOverlay"];
        UIImage *normalImage = [recordImage imageMaskedWithColor:[UIColor lightGrayColor]];

        CGRect frame = CGRectMake(0, 0, recordImage.size.width, 32.0);
        QMAudioRecordButton *button =  [[QMAudioRecordButton alloc] initWithFrame:frame];
        button.delegate = self;
        [button setImage:normalImage forState:UIControlStateNormal];
        [button setImage:normalImage forState:UIControlStateHighlighted];
  
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        button.backgroundColor = [UIColor clearColor];
        button.tintColor = [UIColor lightGrayColor];
        
        _audioRecordButtonItem = button;
    }
    
    return _audioRecordButtonItem;
}


@end
