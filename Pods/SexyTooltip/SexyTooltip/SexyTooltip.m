//
//  SexyTooltip.h
//  SexyTooltip
//
//  Created by JP McGlone on 10/21/14.
//  Copyright (c) 2014 Clinkle. All rights reserved.
//

#import "SexyTooltip.h"
#import <pop/POP.h>

const static UIEdgeInsets defaultPadding = {18, 24, 18, 24};
const static UIEdgeInsets defaultMargin = {10, 10, 10, 10};

@interface SexyTooltip ()
@property (nonatomic, strong) UIView *fromView;
@property (nonatomic, weak) UIView *inView;

@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation SexyTooltip
{
    UIControl *_containerView;
    
    CAShapeLayer *_shapeLayer;
    
    SexyTooltipArrowDirection _arrowDirection;
    CGFloat _arrowOffset;

    NSTimer *_dismissTimer;
}

CG_INLINE CGRect
CGRectFromEdgeInsets(CGRect rect, UIEdgeInsets edgeInsets) {
    return CGRectMake(
                      rect.origin.x + edgeInsets.left,
                      rect.origin.y + edgeInsets.top,
                      rect.size.width - edgeInsets.left - edgeInsets.right,
                      rect.size.height - edgeInsets.top - edgeInsets.bottom
                      );
}

- (id)initWithContentView:(UIView *)contentView
{
    self = [self init];
    if (self) {
        self.contentView = contentView;
    }
    return self;
}

- (id)initWithAttributedString:(NSAttributedString *)attrStr
{
    return [self initWithAttributedString:attrStr
                              sizedToView:[[UIApplication sharedApplication].windows firstObject]
                              withPadding:defaultPadding
                                andMargin:defaultMargin];
}

- (id)initWithAttributedString:(NSAttributedString *)attrStr
                   sizedToView:(UIView *)containerView
{
    return [self initWithAttributedString:attrStr
                              sizedToView:containerView
                              withPadding:defaultPadding
                                andMargin:defaultMargin];
}

- (id)initWithAttributedString:(NSAttributedString *)attrStr
                   sizedToView:(UIView *)containerView
                   withPadding:(UIEdgeInsets)padding
                     andMargin:(UIEdgeInsets)margin
{
    self = [self init];
    if (self) {

        NSAssert(containerView, @"Container view can not be nil.");

        CGSize maxLabelSize = [[self class] maximumContentViewSizeInView:containerView
                                                             withPadding:padding
                                                               andMargin:margin];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, maxLabelSize.width, maxLabelSize.height)];
        label.attributedText = attrStr;
        label.numberOfLines = 0;
        [label sizeToFit];
        self.contentView = label;
        
        self.padding = padding;
        self.margin = margin;
    }
    return self;
}

- (void)dealloc
{
    [self stopObservingFromView];
}

- (NSAttributedString *)attributedString
{
    if ([self.contentView isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)self.contentView;
        return label.attributedText;
    }
    return nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _shapeLayer = [CAShapeLayer layer];
        [self.layer insertSublayer:_shapeLayer atIndex:0];
        
        _containerView = [[UIControl alloc] init];
        [_containerView addTarget:self
                           action:@selector(didTap:)
                 forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_containerView];
        
        // Defaults
        _arrowHeight = 5;
        _attachedToView = YES;
        _padding = defaultPadding;
        _color = [UIColor whiteColor];
        _borderColor = [UIColor clearColor];
        _cornerRadius = 2;
        _arrowMargin = 5;
        _dismissesOnTap = YES;
        _margin = defaultMargin;
        _permittedArrowDirections = @[@(SexyTooltipArrowDirectionDown),
                                      @(SexyTooltipArrowDirectionUp),
                                      @(SexyTooltipArrowDirectionRight),
                                      @(SexyTooltipArrowDirectionLeft)];
        _arrowDirection = SexyTooltipArrowDirectionDown;
    }
    return self;
}

- (void)didTap:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tooltipWillBeTapped:)]) {
        [self.delegate tooltipWillBeTapped:self];
    }

    if ([self.delegate respondsToSelector:@selector(tooltipWasTapped:)]) {
        [self.delegate tooltipWasTapped:self];
    }
    
    if (_dismissesOnTap) {
        [self dismiss];
    }
}

- (void)updateShapeLayer
{
    if (!_isShowing) {
        return;
    }
    
    CGPoint anchorPoint = CGPointZero;
    CGRect bounds = self.bounds;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat topInset = 0,
    rightInset =0,
    bottomInset =0,
    leftInset = 0;
    CGFloat arrowCenter = 0;
    if (_arrowDirection == SexyTooltipArrowDirectionDown) {
        bottomInset = _arrowHeight;
        arrowCenter = bounds.size.width * 0.5;
    } else if (_arrowDirection == SexyTooltipArrowDirectionUp) {
        topInset = _arrowHeight;
        arrowCenter = bounds.size.width * 0.5;
    } else if (_arrowDirection == SexyTooltipArrowDirectionLeft) {
        leftInset = _arrowHeight;
        arrowCenter = bounds.size.height * 0.5;
    } else if (_arrowDirection == SexyTooltipArrowDirectionRight) {
        rightInset = _arrowHeight;
        arrowCenter = bounds.size.height * 0.5;
    }
    
    // Adjust the arrowCenter from the set arrowOffset
    arrowCenter += _arrowOffset;
    
    // Start to the right of top left arc
    [path moveToPoint:CGPointMake(_cornerRadius + leftInset, topInset)];
    
    // Top Arrow
    if (_arrowDirection == SexyTooltipArrowDirectionUp) {
        [path addLineToPoint:CGPointMake(arrowCenter - _arrowHeight, topInset)];
        [path addLineToPoint:CGPointMake(arrowCenter, 0)];
        [path addLineToPoint:CGPointMake(arrowCenter + _arrowHeight, topInset)];
        anchorPoint = CGPointMake(arrowCenter / bounds.size.width, 0);
    }
    
    // Top
    [path addLineToPoint:CGPointMake(bounds.size.width - _cornerRadius - rightInset, topInset)];
    
    // Top right arc
    [path addArcWithCenter:CGPointMake(bounds.size.width - _cornerRadius - rightInset, _cornerRadius + topInset)
                    radius:_cornerRadius startAngle:3 * M_PI_2 endAngle:0 clockwise:YES];
    
    // Right Arrow
    if (_arrowDirection == SexyTooltipArrowDirectionRight) {
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(bounds) - rightInset, arrowCenter - _arrowHeight)];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(bounds), arrowCenter)];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(bounds) - rightInset, arrowCenter + _arrowHeight)];
        anchorPoint = CGPointMake(1, arrowCenter / bounds.size.height);
    }
    
    // Right
    [path addLineToPoint:CGPointMake(bounds.size.width - rightInset, bounds.size.height - _cornerRadius - bottomInset)];
    
    // Bottom right arc
    [path addArcWithCenter:CGPointMake(bounds.size.width - rightInset - _cornerRadius, bounds.size.height - _cornerRadius - bottomInset)
                    radius:_cornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    
    // Bottom Arrow
    if (_arrowDirection == SexyTooltipArrowDirectionDown) {
        [path addLineToPoint:CGPointMake(arrowCenter + _arrowHeight, bounds.size.height - bottomInset)];
        [path addLineToPoint:CGPointMake(arrowCenter, bounds.size.height)];
        [path addLineToPoint:CGPointMake(arrowCenter - _arrowHeight, bounds.size.height - bottomInset)];
        anchorPoint = CGPointMake(arrowCenter / bounds.size.width, 1);
    }
    
    // Bottom
    [path addLineToPoint:CGPointMake(_cornerRadius + leftInset, bounds.size.height - bottomInset)];
    
    // Bottom left arc
    [path addArcWithCenter:CGPointMake(_cornerRadius + leftInset, bounds.size.height - _cornerRadius - bottomInset)
                    radius:_cornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    // Left arrow
    if (_arrowDirection == SexyTooltipArrowDirectionLeft) {
        [path addLineToPoint:CGPointMake(leftInset, arrowCenter + _arrowHeight)];
        [path addLineToPoint:CGPointMake(0, arrowCenter)];
        [path addLineToPoint:CGPointMake(leftInset, arrowCenter - _arrowHeight)];
        anchorPoint = CGPointMake(0, arrowCenter / bounds.size.height);
    }
    
    // Left
    [path addLineToPoint:CGPointMake(leftInset, _cornerRadius + topInset)];
    
    // Top left arc
    [path addArcWithCenter:CGPointMake(_cornerRadius + leftInset, _cornerRadius + topInset)
                    radius:_cornerRadius startAngle:M_PI endAngle:3 * M_PI_2 clockwise:YES];
    
    [path closePath];
    
    //apply path to shapelayer
    _shapeLayer.path = path.CGPath;
    [_shapeLayer setFillColor:_color.CGColor];
    [_shapeLayer setStrokeColor:_borderColor.CGColor];
    _shapeLayer.frame = CGRectMake(0, 0, 100, 30);
    
    [self setFrameAnchorPoint:anchorPoint];
}

- (void)setFrameAnchorPoint:(CGPoint)anchorPoint
{
    CGPoint newPoint = CGPointMake(self.bounds.size.width * anchorPoint.x, self.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(self.bounds.size.width * self.layer.anchorPoint.x, self.bounds.size.height * self.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, self.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, self.transform);
    
    CGPoint position = self.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    self.layer.position = position;
    self.layer.anchorPoint = anchorPoint;
}

- (void)resizeContainerViewToContentSizeWithPadding
{
    _contentView.frame = CGRectMake(
                                    _padding.left,
                                    _padding.top,
                                    _contentView.frame.size.width,
                                    _contentView.frame.size.height
                                    );
    _containerView.frame = CGRectMake(
                                      _containerView.frame.origin.x,
                                      _containerView.frame.origin.y,
                                      _contentView.bounds.size.width + _padding.left + _padding.right,
                                      _contentView.bounds.size.height + _padding.top + _padding.bottom
                                      );
}

- (BOOL)positionTooltipForArrowDirection:(SexyTooltipArrowDirection)arrowDirection
                              aroundRect:(CGRect)rect
                                  inView:(UIView *)view
                                   force:(BOOL)force
{
    CGRect containerViewFrame = _containerView.frame;
    CGSize size = _containerView.bounds.size;
    if (arrowDirection == SexyTooltipArrowDirectionUp || arrowDirection == SexyTooltipArrowDirectionDown) {
        size.height += _arrowHeight;
    } else {
        size.width += _arrowHeight;
    }
    
    CGRect frame = CGRectZero;
    frame.size = size;
    
    // Position the tooltip to the correct side such that the arrow points at the middle, ignoring view's bounds for now
    if (arrowDirection == SexyTooltipArrowDirectionDown) {
        frame.origin = CGPointMake(CGRectGetMidX(rect) - (size.width * 0.5), rect.origin.y - size.height);
        containerViewFrame.origin = CGPointMake(0, 0);
    } else if (arrowDirection == SexyTooltipArrowDirectionUp) {
        frame.origin = CGPointMake(CGRectGetMidX(rect) - (size.width * 0.5), CGRectGetMaxY(rect));
        containerViewFrame.origin = CGPointMake(0, _arrowHeight);
    } else if (arrowDirection == SexyTooltipArrowDirectionLeft) {
        frame.origin = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect) - (size.height * 0.5));
        containerViewFrame.origin = CGPointMake(_arrowHeight, 0);
    } else if (arrowDirection == SexyTooltipArrowDirectionRight) {
        frame.origin = CGPointMake(rect.origin.x - size.width, CGRectGetMidY(rect) - (size.height * 0.5));
        containerViewFrame.origin = CGPointMake(0, 0);
    }
    
    // If it already fits, just finish here
    CGRect bounds = view.bounds;
    if ([view isKindOfClass:[UIScrollView class]]) {
        bounds.origin = CGPointZero;
        bounds.size = ((UIScrollView *)self.inView).contentSize;
    }
    CGRect insetRect = CGRectFromEdgeInsets(bounds, _margin);
    
    // Sometimes the first time through, NONE of the permitted arrow directions will work. In that case, get rid of the margin
    // by making it infinite.
    if (force && (self.bounds.size.width == 0 || self.bounds.size.height == 0)) {
        insetRect = CGRectInset(bounds, -CGFLOAT_MAX, -CGFLOAT_MAX);
        NSLog(@"Tooltip couldn't fit with any of the permitted arrow directions, removing margin and using highest priority arrow direction");
    }
    
    if (CGRectContainsRect(insetRect, frame)) {
        _arrowOffset = 0;
        self.frame = frame;
        _containerView.frame = containerViewFrame;
        return YES;
    } else {
        CGRect originalFrame = frame;
        
        // Otherwise, make it fit the best we can
        if (arrowDirection == SexyTooltipArrowDirectionDown || arrowDirection == SexyTooltipArrowDirectionUp) {
            if (CGRectGetMinX(frame) <= CGRectGetMinX(insetRect)) {
                frame.origin.x = _margin.left;
            }
            if (CGRectGetMaxX(frame) >= CGRectGetMaxX(insetRect)) {
                frame.origin.x = CGRectGetMaxX(view.bounds) - frame.size.width - _margin.right;
            }
        } else if (arrowDirection == SexyTooltipArrowDirectionLeft || arrowDirection == SexyTooltipArrowDirectionRight) {
            if (CGRectGetMinY(frame) <= CGRectGetMinY(insetRect)) {
                frame.origin.y = _margin.top;
            }
            if (CGRectGetMaxY(frame) >= CGRectGetMaxY(insetRect)) {
                frame.origin.y = CGRectGetMaxY(view.bounds) - frame.size.height - _margin.bottom;
            }
        }
        
        if (CGRectContainsRect(insetRect, frame)) {
            BOOL good = NO;
            CGFloat mid;
            switch (arrowDirection) {
                case SexyTooltipArrowDirectionDown:
                case SexyTooltipArrowDirectionUp:
                    mid = frame.size.width * 0.5;
                    _arrowOffset = originalFrame.origin.x - frame.origin.x;
                    break;
                case SexyTooltipArrowDirectionRight:
                case SexyTooltipArrowDirectionLeft:
                    mid = frame.size.height * 0.5;
                    _arrowOffset = originalFrame.origin.y - frame.origin.y;
                    break;
            }
            
            CGFloat max = mid - _cornerRadius - _arrowHeight;
            CGFloat min = -mid + _cornerRadius + _arrowHeight;
            if (_arrowOffset < min) {
                _arrowOffset = min;
            } else if (_arrowOffset > max) {
                _arrowOffset = max;
            } else {
                good = YES;
            }
            
            if (good) {
                self.frame = frame;
                _containerView.frame = containerViewFrame;
                return YES;
            }
        }
        
        // If it still doesn't fit, and we're forcing it, center the contents in the superview, so we can see most of the tooltip's contens
        if (force) {
            self.frame = originalFrame;
            _containerView.frame = containerViewFrame;
            return YES;
        }
    }
    return NO;
}

#pragma mark - Presenting
- (void)presentFromRect:(CGRect)rect
                 inView:(UIView *)view
               animated:(BOOL)animated
{
    if (self.isAnimating) {
        [self.layer pop_removeAllAnimations];
        self.layer.transform = CATransform3DIdentity;
    }   
    [view addSubview:self];
    
    [self resizeContainerViewToContentSizeWithPadding];
    
    BOOL good = NO;
    for (NSNumber *permittedArrowDirection in _permittedArrowDirections) {
        SexyTooltipArrowDirection arrowDirection = [permittedArrowDirection integerValue];
        if ([self positionTooltipForArrowDirection:arrowDirection aroundRect:rect inView:view force:NO]) {
            _arrowDirection = arrowDirection;
            good = YES;
            break;
        }
    }
    
    if (!good) {
        SexyTooltipArrowDirection arrowDirection;
        if (_isShowing || _permittedArrowDirections.count == 0) {
            arrowDirection = _arrowDirection;
        } else {
            arrowDirection = [[_permittedArrowDirections firstObject] integerValue];
        }
        [self positionTooltipForArrowDirection:arrowDirection aroundRect:rect inView:view force:YES];
    }
    
    _isShowing = YES;
    [self updateShapeLayer];
    
    if (animated) {
        self.isAnimating = YES;
        self.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1.0);
        
        POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        springAnimation.springSpeed = 14;
        springAnimation.springBounciness = 7;;
        springAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
        springAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            self.isAnimating = NO;
        };
        [self.layer pop_addAnimation:springAnimation forKey:@"size"];
    }
    
    if ([self.delegate respondsToSelector:@selector(tooltipDidPresent:)]) {
        [self.delegate tooltipDidPresent:self];
    }
}

- (void)setContentView:(UIView *)contentView
{
    [_contentView removeFromSuperview];
    
    _contentView = contentView;
    CGRect contentViewBounds = _contentView.bounds;
    contentViewBounds.size.width += _padding.left + _padding.right;
    contentViewBounds.size.height += _padding.top + _padding.bottom;
    _containerView.frame = contentViewBounds;
    [_containerView addSubview:_contentView];
    
    [self resizeContainerViewToContentSizeWithPadding];
    [self updateShapeLayer];
}

- (void)stopObservingFromView
{
    if (_fromView.layer) {
        [_fromView.layer removeObserver:self forKeyPath:@"position"];
    }
}

- (void)setFromView:(UIView *)fromView
{
    [self stopObservingFromView];
    _fromView = fromView;
    [fromView.layer addObserver:self
                     forKeyPath:@"position"
                        options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                        context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"position"]) {
        if (_attachedToView
            && object == self.fromView.layer)
        {
            NSValue *new = change[NSKeyValueChangeNewKey];
            NSValue *old = change[NSKeyValueChangeOldKey];
            CGRect newFrame = [new isKindOfClass:[NSNull class]] ? CGRectZero : [new CGRectValue];
            CGRect oldFrame = [old isKindOfClass:[NSNull class]] ? CGRectZero : [old CGRectValue];
            CGFloat xDiff = (newFrame.origin.x - oldFrame.origin.x);
            CGFloat yDiff = (newFrame.origin.y - oldFrame.origin.y);
            BOOL didChangePosition = !(xDiff == 0 && yDiff == 0);

            if (didChangePosition) {
                if (self.isAnimating) {
                    // do the transition in a "rudimentary" way
                    CGRect newFrame = self.frame;
                    newFrame.origin.x += xDiff;
                    newFrame.origin.y += yDiff;
                    self.frame = newFrame;
                } else {
                    [self presentFromNewPosition];
                }
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)presentFromNewPosition
{
    [self presentFromView:self.fromView
                   inView:self.inView
                 animated:NO];
}

- (void)presentFromRect:(CGRect)rect inView:(UIView *)view
{
    [self presentFromRect:rect inView:view animated:YES];
}

- (void)presentFromPoint:(CGPoint)point
                  inView:(UIView *)view
                animated:(BOOL)animated
{
    [self presentFromRect:CGRectMake(point.x, point.y, 0, 0)
                   inView:view
                 animated:animated];
}

- (void)presentFromPoint:(CGPoint)point inView:(UIView *)view
{
    [self presentFromPoint:point inView:view animated:YES];
}

- (void)presentFromView:(UIView *)fromView
                 inView:(UIView *)view
             withMargin:(CGFloat)margin
               animated:(BOOL)animated
{
    self.fromView = fromView;
    self.inView = view;
    CGRect rect = CGRectInset(self.fromView.frame, -margin, -margin);
    CGRect convertedRect = [self.fromView.superview convertRect:rect toView:self.inView];
    [self presentFromRect:convertedRect
                   inView:self.inView
                 animated:animated];
}

- (void)presentFromView:(UIView *)fromView
                 inView:(UIView *)view
               animated:(BOOL)animated
{
    [self presentFromView:fromView
                   inView:view
               withMargin:_arrowMargin
                 animated:animated];
}

- (void)presentFromView:(UIView *)fromView inView:(UIView *)view
{
    [self presentFromView:fromView
                   inView:view
                 animated:YES];
}

- (void)presentFromView:(UIView *)view
             withMargin:(CGFloat)margin
               animated:(BOOL)animated
{
    [self presentFromView:view
                   inView:view.superview
               withMargin:margin
                 animated:animated];
}

- (void)presentFromView:(UIView *)view withMargin:(CGFloat)margin
{
    [self presentFromView:view
               withMargin:margin
                 animated:YES];
}

- (void)presentFromView:(UIView *)view
{
    [self presentFromView:view
               withMargin:_arrowMargin];
}

- (void)presentFromView:(UIView *)view animated:(BOOL)animated
{
    [self presentFromView:view
               withMargin:_arrowMargin
                 animated:animated];
}

- (void)cleanupForDismissal
{
    [self removeFromSuperview];
    self.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
}

#pragma mark - Dismiss
- (void)dismissAnimated:(BOOL)animated
{
    [self cancelDismissTimer];
    
    if (self.isAnimating) {
        [self.layer pop_removeAllAnimations];
        self.layer.transform = CATransform3DIdentity;
    }
    _isShowing = NO;
    if (animated) {
        self.isAnimating = YES;
        POPBasicAnimation *expandAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        expandAnimation.duration = kSexyTooltipDismissDurationExpand;
        expandAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.05, 1.05)];
        expandAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            POPBasicAnimation *shrinkAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
            shrinkAnimation.duration = kSexyTooltipDismissDurationExpand;
            shrinkAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.01, 0.01)];
            shrinkAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
                [self cleanupForDismissal];
                self.isAnimating = NO;
            };
            [self.layer pop_addAnimation:shrinkAnimation forKey:@"size"];
        };
        [self.layer pop_addAnimation:expandAnimation forKey:@"size"];
    } else {
        [self cleanupForDismissal];
    }

    self.fromView = nil;
    
    if ([self.delegate respondsToSelector:@selector(tooltipDidDismiss:)]) {
        [self.delegate tooltipDidDismiss:self];
    }
}

- (void)dismiss
{
    [self dismissAnimated:YES];
}

- (void)dismissInTimeInterval:(NSTimeInterval)timeInterval
{
    [self dismissInTimeInterval:timeInterval animated:YES];
}

- (void)cancelDismissTimer
{
    [_dismissTimer invalidate];
    _dismissTimer = nil;
}

- (void)dismissInTimeInterval:(NSTimeInterval)timeInterval
                     animated:(BOOL)animated
{
    [self cancelDismissTimer];
    _dismissTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                     target:self
                                                   selector:@selector(dismissTimer:)
                                                   userInfo:@(animated)
                                                    repeats:NO];
}

- (void)dismissTimer:(NSTimer *)timer
{
    [self dismissAnimated:[timer.userInfo boolValue]];
}

- (void)setHasShadow:(BOOL)hasShadow
{
    _hasShadow = hasShadow;
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = hasShadow ? CGSizeMake(0, 2) : CGSizeZero;
    self.layer.shadowRadius = hasShadow ? 3 : 0;
    self.layer.shadowOpacity = hasShadow ? 0.15 : 0;
    self.layer.shadowColor = hasShadow ? [UIColor blackColor].CGColor : [UIColor clearColor].CGColor;
}

#pragma mark - content size
- (CGSize)maximumContentViewSizeInView:(UIView *)view
{
    return [[self class] maximumContentViewSizeInView:view
                                          withPadding:self.padding
                                            andMargin:self.margin];
}

+ (CGSize)maximumContentViewSizeWithDefaultPaddingAndMarginsInView:(UIView *)view
{
    return [[self class] maximumContentViewSizeInView:view
                                          withPadding:defaultPadding
                                            andMargin:defaultMargin];
}

+ (CGSize)maximumContentViewSizeInView:(UIView *)view
                           withPadding:(UIEdgeInsets)padding
                             andMargin:(UIEdgeInsets)margin
{
    CGRect sizeRect = CGRectFromEdgeInsets(view.bounds, padding);
    sizeRect = CGRectInset(sizeRect, margin.left, margin.right);
    return sizeRect.size;
}

@end