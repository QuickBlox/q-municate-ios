//
//  QMContentView.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContentView.h"
#import "QMUsersUtils.h"

@interface QMContentView()

@property (nonatomic, strong, readonly) NSTimer *timer;
@property (nonatomic, assign) double_t timeInterval;

@end

@implementation QMContentView

/**
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation. 
 */
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.avatarView.imageViewType = QMImageViewTypeCircle;
}


#pragma mark - Show/Hide

- (void)show {
    [self setHidden:NO];
}

- (void)hide {
    [self setHidden:YES];
}


#pragma mark -

- (void)updateViewWithUser:(QBUUser *)user conferenceType:(QBConferenceType)conferenceType{
    UIImage *placeholder = [UIImage imageNamed:@"upic_call"];
    NSURL *url = [QMUsersUtils userAvatarURL:user];
    [self.avatarView setImageWithURL:url
                         placeholder:placeholder
                             options:SDWebImageLowPriority
                            progress:
     ^(NSInteger receivedSize, NSInteger expectedSize) {}
                      completedBlock:
     ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];

    self.fullNameLabel.text = user.fullName;
    if( conferenceType == QBConferenceTypeAudio ){
        self.statusLabel.text = NSLocalizedString(@"QM_STR_CALLING", nil);
    }
    else{
        self.statusLabel.text = NSLocalizedString(@"QM_STR_VIDEO_CALLING", nil);
    }
    
    [self layoutSubviews];
}

- (void)updateViewWithStatus:(NSString *)status {
    self.statusLabel.text = status;
}

- (void)startTimerIfNeeded {
    if( [_timer isValid] ){
        return;
    }
    _timeInterval = 0;
    self.statusLabel.text = [NSString stringWithFormat:@"%02u:%02u", (int)(_timeInterval/60), (int)fmod(_timeInterval, 60)];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateStatusLabel) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)startTimer {
    // stop if running
    [self stopTimer];
    [self startTimerIfNeeded];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
    _timeInterval = 0;
}

// selector:
- (void)updateStatusLabel {
    self.statusLabel.text = [NSString stringWithFormat:@"%02u:%02u", (int)(_timeInterval/60), (int)fmod(_timeInterval, 60)];
    _timeInterval++;
}

@end
