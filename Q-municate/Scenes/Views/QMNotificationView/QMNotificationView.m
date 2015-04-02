//
//  QMNotificationView.m
//  Q-municate
//
//  Created by Andrey Ivanov on 19.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMNotificationView.h"
#import "QMBlurView.h"

static void * kQMNavigationBarObservationContext = &kQMNavigationBarObservationContext;
NSString *const kQMNavigationBarBoundsKeyPath = @"parentViewController.navigationController.navigationBar.bounds";

const CGFloat kQMNotificationViewHeight = 30.0f;
const NSTimeInterval kQMNotificationViewDefaultShowDuration = 2.0;

@interface QMNotificationView()

@property (strong, nonatomic) QMBlurView *blurView;
@property (strong, nonatomic) UIColor* tintColor;
@property (strong, nonatomic) UIColor* contentColor;
@property (strong, nonatomic) UILabel *label;

@property (weak, nonatomic) UIViewController *parentViewController;

@end

@implementation QMNotificationView

- (void)dealloc {
    
    NSNotificationCenter *defaultNotificationCenter = [NSNotificationCenter defaultCenter];
    [defaultNotificationCenter removeObserver:self];
    
     [self removeObserver:self forKeyPath:kQMNavigationBarBoundsKeyPath context:kQMNavigationBarObservationContext];
}

+ (QMNotificationView *)showInViewController:(UIViewController *)viewController {
    
    QMNotificationView *notificationView =
    [[QMNotificationView alloc] initWithTitle:@"Отсутствует подключение к интернету"
                         parentViewController:viewController];
    
    notificationView.tintColor = [UIColor redColor];
    [notificationView setVisible:YES animated:YES completion:^{
        
    }];
    
    return notificationView;
}

- (instancetype)initWithTitle:(NSString *)title parentViewController:(UIViewController *)parentViewController {
    
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.blurView = [[QMBlurView alloc] initWithFrame:CGRectZero];
    
        [self addSubview:self.blurView];
        self.parentViewController = parentViewController;
        
        NSNotificationCenter *defaultNotificationCenter = [NSNotificationCenter defaultCenter];
        [defaultNotificationCenter addObserver:self selector:@selector(nav:)
                                          name:@"UINavigationControllerWillShowViewControllerNotification"
                                        object:nil];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.textColor = [UIColor whiteColor];
        self.label.numberOfLines = 0;
        self.label.lineBreakMode = NSLineBreakByTruncatingTail;
        self.label.textAlignment = NSTextAlignmentCenter;
        UIFontDescriptor *fontDescription = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
        self.label.font = [UIFont fontWithDescriptor:fontDescription size:15];
        self.label.text = title;
        [self addSubview:self.label];
        
        self.autoresizingMask = 
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        
        self.blurView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        
        self.label.autoresizingMask =
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        
        [self addObserver:self forKeyPath:kQMNavigationBarBoundsKeyPath
                  options:NSKeyValueObservingOptionNew
                  context:kQMNavigationBarObservationContext];
    }
    
    return self;
}

#pragma mark - Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kQMNavigationBarObservationContext && [keyPath isEqualToString:kQMNavigationBarBoundsKeyPath]) {
        self.frame = self.isVisible ? [self visibleFrame] : [self hiddenFrame];
        
        self.label.frame = CGRectMake(0, self.frame.size.height - kQMNotificationViewHeight, self.frame.size.width, kQMNotificationViewHeight);
    }
    else {
       
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    [self.blurView setBlurTintColor:tintColor];
    self.contentColor = [self legibleTextColorForBlurTintColor:tintColor];
}

- (UIColor*)legibleTextColorForBlurTintColor:(UIColor*)blurTintColor {
    CGFloat r, g, b, a;
    BOOL couldConvert = [blurTintColor getRed:&r
                                        green:&g
                                         blue:&b
                                        alpha:&a];
    
    UIColor* textColor = [UIColor whiteColor];
    
    CGFloat average = (r+g+b)/3.0;
    if (couldConvert && average > 0.65){
        textColor = [[UIColor alloc] initWithWhite:0.2 alpha:1.0];
    }
    
    return textColor;
}

- (void)setContentColor:(UIColor *)contentColor {
    
    if (![_contentColor isEqual:contentColor]) {
        _contentColor = contentColor;
        self.label.textColor = _contentColor;
    }
}

#pragma mark - layout

- (void)nav:(NSNotification *)note {
    
    if (self.isVisible && [self.parentViewController isEqual:note.object]) {
        
        __block typeof(self) weakself = self;
        [UIView animateWithDuration:0.1 animations:^{
            CGRect endFrame;
            [weakself animationFramesForVisible:weakself.isVisible
                                     startFrame:nil
                                       endFrame:&endFrame];
            
            [weakself setFrame:endFrame];
            [weakself updateConstraints];
        }];
    }
}

#pragma mark - presentation

- (void)setVisible:(BOOL)visible
          animated:(BOOL)animated
        completion:(dispatch_block_t)completion {
    
    if (_visible != visible) {
        
        NSTimeInterval animationDuration = animated ? 0.3 : 0.0;
        
        CGRect startFrame, endFrame;
        [self animationFramesForVisible:visible
                             startFrame:&startFrame
                               endFrame:&endFrame];
        
        if (!self.superview) {
            
            self.frame = startFrame;
            
            if (self.parentViewController.navigationController) {
                [self.parentViewController.navigationController.view insertSubview:self
                                                                      belowSubview:self.parentViewController.navigationController.navigationBar];
            }
            else {
                
                [self.parentViewController.view addSubview:self];
            }
        }
        
        __block typeof(self) weakself = self;
        [UIView animateWithDuration:animationDuration animations:^{
            
            [weakself setFrame:endFrame];
            
        } completion:^(BOOL finished) {
            
            if (!visible) {
                [weakself removeFromSuperview];
            }
            
            if (completion) {
                completion();
            }
            
             self.label.frame = CGRectMake(0,
                                           startFrame.size.height - kQMNotificationViewHeight,
                                           startFrame.size.width,
                                           kQMNotificationViewHeight);
        }];
        
        _visible = visible;
    }
    else if (completion) {
        completion();
    }
}

- (void)animationFramesForVisible:(BOOL)visible startFrame:(CGRect*)startFrame endFrame:(CGRect*)endFrame {
    
    if (startFrame) *startFrame = visible ? [self hiddenFrame]:[self visibleFrame];
    if (endFrame) *endFrame = visible ? [self visibleFrame] : [self hiddenFrame];
}


#pragma mark - frame calculation

//Workaround as there is a bug: sometimes, when accessing topLayoutGuide, it will render contentSize of UITableViewControllers to be {0, 0}
- (CGFloat)topLayoutGuideLengthCalculation {
    
    CGFloat top = MIN([UIApplication sharedApplication].statusBarFrame.size.height,
                      [UIApplication sharedApplication].statusBarFrame.size.width);
    
    if (self.parentViewController.navigationController && !self.parentViewController.navigationController.isNavigationBarHidden) {
        
        top += CGRectGetHeight(self.parentViewController.navigationController.navigationBar.frame);
    }
    
    return top;
}

- (CGRect)visibleFrame {
    
    UIViewController* viewController = self.parentViewController.navigationController ?: self.parentViewController;
    
    if (!viewController.isViewLoaded) {
        return CGRectZero;
    }
    
    CGFloat topLayoutGuideLength = [self topLayoutGuideLengthCalculation];
    
    CGSize transformedSize = CGSizeApplyAffineTransform(viewController.view.frame.size,
                                                        viewController.view.transform);
    CGRect displayFrame = CGRectMake(0,
                                     0,
                                     fabs(transformedSize.width),
                                     kQMNotificationViewHeight + topLayoutGuideLength);
    
    return displayFrame;
}

- (CGRect)hiddenFrame {
    
    UIViewController *viewController = self.parentViewController.navigationController ?: self.parentViewController;
    
    if (!viewController.isViewLoaded) {
        return CGRectZero;
    }
    
    CGFloat topLayoutGuideLength = [self topLayoutGuideLengthCalculation];
    
    CGSize transformedSize = CGSizeApplyAffineTransform(viewController.view.frame.size, viewController.view.transform);
    CGRect offscreenFrame = CGRectMake(0, -kQMNotificationViewHeight - topLayoutGuideLength,
                                       fabs(transformedSize.width),
                                       kQMNotificationViewHeight + topLayoutGuideLength);
    
    return offscreenFrame;
}

- (CGSize)intrinsicContentSize {
    
    CGRect currentRect = self.visible ? [self visibleFrame] : [self hiddenFrame];
    return currentRect.size;
}

- (void)dismissAnimated:(BOOL)animated {
    __block typeof(self) weakself = self;
    
    [UIView animateWithDuration:0.1 animations:^{
        

        
    } completion:^(BOOL finished) {
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakself setVisible:NO animated:animated completion:nil];
        });
    }];
}

@end

