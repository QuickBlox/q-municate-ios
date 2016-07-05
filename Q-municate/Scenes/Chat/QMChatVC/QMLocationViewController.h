//
//  QMLocationViewController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/4/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QMLocationVCState) {
    
    QMLocationVCStateView, // default
    QMLocationVCStateSend
};

@interface QMLocationViewController : UIViewController

/**
 *  Current view controller state.
 */
@property (readonly, assign, nonatomic) QMLocationVCState state;

/**
 *  Send button action (for send view controller state).
 *
 *  @note centerCoordinate param in block is center coordinate on map when the send button was pressed.
 */
@property (copy, nonatomic) void(^sendButtonPressed)(CLLocationCoordinate2D centerCoordinate);

/**
 *  Init with view controller state.
 *
 *  @param state QMLocationVCState value
 *
 *  @return QMLocationViewController instance
 */
- (instancetype)initWithState:(QMLocationVCState)state;

/**
 *  Init with view controller state and location coordinate.
 *
 *  @param state              QMLocationVCState value
 *  @param locationCoordinate location coordinate to set and mark
 *
 *  @return QMLocationViewController instance
 */
- (instancetype)initWithState:(QMLocationVCState)state locationCoordinate:(CLLocationCoordinate2D)locationCoordinate;

/**
 *  Set and mark location.
 *
 *  @param locationCoordinate location coordinate
 */
- (void)setLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate;

@end
