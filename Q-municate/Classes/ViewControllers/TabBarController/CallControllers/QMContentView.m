//
//  QMContentView.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContentView.h"
#import "QMUsersUtils.h"

const NSTimeInterval kRefreshTimeInterval = 1.f;

@interface QMContentView()

@property (nonatomic, strong, readonly) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval timeInterval;

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

- (void)updateViewWithUser:(QBUUser *)user conferenceType:(QBRTCConferenceType)conferenceType isOpponentCaller:(BOOL)isOpponentCaller {
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
    
    // we are establishing a connection with opponent
    if( isOpponentCaller ){
        self.statusLabel.text = NSLocalizedString(@"QM_STR_CONNECTING", nil);
    }
    else if( conferenceType == QBRTCConferenceTypeAudio ) {
        self.statusLabel.text = isOpponentCaller ? NSLocalizedString(@"QM_STR_CONNECTING", nil) : NSLocalizedString(@"QM_STR_CALLING", nil);
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
    _timeInterval = 0.0f;
    self.statusLabel.text = [self stringWithTimeDuration:self.timeInterval];
    _timer = [NSTimer scheduledTimerWithTimeInterval:kRefreshTimeInterval target:self selector:@selector(updateStatusLabel) userInfo:nil repeats:YES];
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
    _timeInterval = 0.0f;
}

// selector:
- (void)updateStatusLabel {
    self.timeInterval += kRefreshTimeInterval;
    self.statusLabel.text = [self stringWithTimeDuration:self.timeInterval];
}

#pragma mark - Helper

- (NSString *)stringWithTimeDuration:(NSTimeInterval )timeDuration {
    
    NSInteger minutes = timeDuration / 60;
    NSInteger seconds = (NSInteger)timeDuration % 60;
    
    NSString *timeStr = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    
    return timeStr;
}

@end
