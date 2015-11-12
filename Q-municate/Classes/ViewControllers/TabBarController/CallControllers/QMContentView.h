//
//  QMContentView.h
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMImageView.h"

@interface QMContentView : UIView

@property (nonatomic, weak) IBOutlet UILabel *fullNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet QMImageView *avatarView;

- (void)updateViewWithUser:(QBUUser *)user conferenceType:(QBRTCConferenceType)conferenceType isOpponentCaller:(BOOL)isOpponentCaller;
- (void)updateViewWithStatus:(NSString *)status;

- (void)startTimerIfNeeded;
// start/restart timer
- (void)startTimer;
- (void)stopTimer;

#pragma mark - Show/Hide

- (void)show;
- (void)hide;

@end
