//
//  QMLocationPinView.h
//  Q-municate
//
//  Created by Injoit on 7/5/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Pin origin center.
 *
 *  @note Use this to shift pin view on X point.
 */
extern const CGFloat QMLocationPinViewOriginPinCenter;

@interface QMLocationPinView : UIView

/**
 *  Whether pin is rised or not.
 *
 *  @note Setting this property to a positive value will perform pin set with no animation.
 */
@property (assign, nonatomic) BOOL pinRaised;

/**
 *  Set pin rised.
 *
 *  @param pinRaised whether pin should be rised or not
 *  @param animated  whether rise should be performed with animation
 */
- (void)setPinRaised:(BOOL)pinRaised animated:(BOOL)animated;

@end
