//
//  QMCallInfoView.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMCallInfoView class interface.
 *  Used as call info to display opponent user info and custom text.
 */
@interface QMCallInfoView : UIView

/**
 *  Bottom text.
 *
 *  @discussion Use this to display custom info (e.g. call state or timer).
 */
@property (copy, nonatomic, nullable) NSString *bottomText;

/**
 *  Call info view with user.
 *
 *  @param user user to configure call info with
 *
 *  @see QMCallInfoView xib.
 *
 *  @return QMCallInfoView instance
 */
+ (instancetype)callInfoViewWithUser:(QBUUser *)user;

/**
 *  Video call info view with user.
 *
 *  @param user user user to configure video call info with
 *
 *  @see QMVideoCallInfoView xib.
 *
 *  @return QMCallInfoView instance
 */
+ (instancetype)videoCallInfoViewWithUser:(QBUUser *)user;

/**
 *  Preferred (but not required) video call info view height.
 *
 *  @return Preferred height value
 */
+ (CGFloat)preferredVideoInfoViewHeight;

/**
 *  Set text color for full name label and bottom text.
 *
 *  @param textColor color
 */
- (void)setTextColor:(UIColor *)textColor;

@end

NS_ASSUME_NONNULL_END
