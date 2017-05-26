//
//  QMBaseMediaCell.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/07/17.
//
//

#import "QMBaseMediaCell.h"
#import "QMMediaViewDelegate.h"
#import "QMChatResources.h"
#import "QMMediaPresenter.h"

@implementation QMBaseMediaCell

@synthesize presenter = _presenter;
@synthesize duration = _duration;
@synthesize offset = _offset;
@synthesize currentTime = _currentTime;
@synthesize progress = _progress;
@synthesize isReady = _isReady;
@synthesize isActive = _isActive;

//MARK: - NSObject

- (void)deallock {
    NSLog(@"deallock base cell");
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    NSString *imageName  = @"play_icon";
    UIImage *buttonImage = [QMChatResources imageNamed:imageName];
    
    if (buttonImage) {
        
        [self.mediaPlayButton setImage:buttonImage
                              forState:UIControlStateNormal];

    }
    self.mediaPlayButton.hidden = NO;
    self.mediaPlayButton.enabled = NO;
    
    [self.mediaPlayButton setTitle:nil
                          forState:UIControlStateNormal];
    
    [self.mediaPlayButton addTarget:self
                             action:@selector(activateMedia:)
                   forControlEvents:UIControlEventTouchDown];
    
    self.circularProgress.hideProgressIcons = YES;
    self.durationLabel.hidden = YES;
    self.durationLabel.text = nil;
    [self.circularProgress startSpinProgressBackgroundLayer];
    
    self.progressLabel.text = nil;
    
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
}


- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.isActive = NO;
    self.isReady = NO;
    self.previewImageView.image = nil;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    
    if (_currentTime == currentTime) {
        return;
    }
    
    _currentTime = currentTime;
    
    self.durationLabel.text = [self timestampString:currentTime forDuration:_duration];

}

- (void)setProgress:(CGFloat)progress {
    
    if (progress > 0.0) {
        
        self.progressLabel.hidden = NO;
        self.circularProgress.hidden = NO;
        [self.circularProgress stopSpinProgressBackgroundLayer];
    }
    
    self.progressLabel.text = [NSString stringWithFormat:@"%2.0f%%", progress * 100.0f];
    [self.circularProgress setProgress:progress];
}

- (void)setDuration:(NSInteger)duration {
    
//    if (_duration == duration) {
//        return;
//    }
    
    _duration = duration;
    
    self.durationLabel.text = [self timestampString:duration];
}

- (void)setIsReady:(BOOL)isReady {
    
    _isReady = isReady;
    
    isReady ? [self.circularProgress stopSpinProgressBackgroundLayer] : [self.circularProgress startSpinProgressBackgroundLayer];

    self.circularProgress.hidden = isReady;
    self.progressLabel.hidden = isReady;
    self.durationLabel.hidden = !isReady;
    self.mediaPlayButton.enabled = isReady;
}

- (void)setThumbnailImage:(UIImage *)image {
    
    self.previewImageView.image = image;
    [self setNeedsLayout];
}

- (void)setImage:(UIImage *)image {
    
    self.previewImageView.image = image;
    [self setNeedsLayout];
}

- (void)setIsActive:(BOOL)isActive {
    
    if (_isActive == isActive) {
        return;
    }
    _isActive = isActive;
    
    NSString *imageName = isActive ? @"pause_icon" : @"play_icon";
    UIImage *buttonImage = [QMChatResources imageNamed:imageName];
    
    if (buttonImage) {
        
        [self.mediaPlayButton setImage:buttonImage
                              forState:UIControlStateNormal];
        [self.mediaPlayButton setImage:buttonImage
                              forState:UIControlStateDisabled];
    }
    
    if (!isActive) {
    self.durationLabel.text = [self timestampString:self.duration];
    }
}

- (IBAction)activateMedia:(id)sender {
    
    [self.presenter activateMedia];
}

- (NSString *)timestampString:(NSTimeInterval)duration {
    
    if (duration < 60)
    {
        
        return [NSString stringWithFormat:@"0:%02d", (int)round(duration)];
        
    }
    else if (duration < 3600)
    {
        return [NSString stringWithFormat:@"%d:%02d", (int)duration / 60, (int)duration % 60];
    }
    
    return [NSString stringWithFormat:@"%d:%02d:%02d", (int)duration / 3600, (int)duration / 60, (int)duration % 60];
}

- (NSString *)timestampString:(NSTimeInterval)currentTime forDuration:(NSTimeInterval)duration
{
    if (duration < 60)
    {
        
        if (currentTime < duration)
        {
            return [NSString stringWithFormat:@"0:%02d", (int)round(currentTime)];
        }
        return [NSString stringWithFormat:@"0:%02d", (int)ceil(currentTime)];
    }
    else if (duration < 3600)
    {
        return [NSString stringWithFormat:@"%d:%02d", (int)currentTime / 60, (int)currentTime % 60];
    }
    
    return [NSString stringWithFormat:@"%d:%02d:%02d", (int)currentTime / 3600, (int)currentTime / 60, (int)currentTime % 60];
}


- (CALayer *)maskLayerFromImage:(UIImage *)image {
    
    CALayer *layer = [CALayer layer];
    layer.frame = self.bounds;
    layer.contents = (id)[image CGImage];
    layer.contentsScale = [image scale];
    layer.rasterizationScale = [image scale];
    CGSize imageSize = [image size];
    
    NSAssert(image.resizingMode == UIImageResizingModeStretch || UIEdgeInsetsEqualToEdgeInsets(image.capInsets, UIEdgeInsetsZero),
             @"the resizing mode of image should be stretch; if not, then its insets must be all-zero");
    
    UIEdgeInsets insets = [image capInsets];
    
    // These are lifted from what UIImageView does by experimentation. Without these exact values, the stretching is slightly off.
    const CGFloat halfPixelFudge = 0.49f;
    const CGFloat otherPixelFudge = 0.02f;
    // Convert to unit coordinates for the contentsCenter property.
    CGRect contentsCenter = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    if (insets.left > 0 || insets.right > 0) {
        contentsCenter.origin.x = ((insets.left + halfPixelFudge) / imageSize.width);
        contentsCenter.size.width = (imageSize.width - (insets.left + insets.right + 1.f) + otherPixelFudge) / imageSize.width;
    }
    if (insets.top > 0 || insets.bottom > 0) {
        contentsCenter.origin.y = ((insets.top + halfPixelFudge) / imageSize.height);
        contentsCenter.size.height = (imageSize.height - (insets.top + insets.bottom + 1.f) + otherPixelFudge) / imageSize.height;
    }
    layer.contentsGravity = kCAGravityResize;
    layer.contentsCenter = contentsCenter;
    
    return layer;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    } else {
        return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
}

@end
