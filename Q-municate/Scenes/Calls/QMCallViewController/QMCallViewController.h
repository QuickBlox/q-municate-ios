//
//  QMCallViewController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMCallViewDelegate.h"

typedef NS_ENUM(NSUInteger, QMCallViewState) {
    /**
     *  Incomind audio call.
     */
    QMCallViewStateMaximized,
    /**
     *  Incoming video call.
     */
    QMCallViewStateMinimized,
    /**
     *  Outgoing audio call.
     */
    QMCallViewStateHidden

};
/**
 *  QMCallViewController possible states.
 */
typedef NS_ENUM(NSUInteger, QMCallState) {
    /**
     *  Incomind audio call.
     */
    QMCallStateIncomingAudioCall,
    /**
     *  Incoming video call.
     */
    QMCallStateIncomingVideoCall,
    /**
     *  Outgoing audio call.
     */
    QMCallStateOutgoingAudioCall,
    /**
     *  Outgoing video call.
     */
    QMCallStateOutgoingVideoCall,
    /**
     *  Active audio call.
     */
    QMCallStateActiveAudioCall,
    /**
     *  Active video call.
     */
    QMCallStateActiveVideoCall
};

/**
 *  QMCallViewController clas interface.
 *  Used as main calls managing view controller.
 */
@interface QMCallViewController : UIViewController

@property (weak, nonatomic)  id<QMCallViewDelegate> callViewDelegate;
@property (assign, nonatomic) QMCallViewState viewState;

// Unavailable initializers
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 *  Call view controller with state.
 *
 *  @param callState specific call view controller state
 *
 *  @see QMCallManager class, QMCallState enum.
 *
 *  @return QMCallViewController with a specific state
 */

+ (instancetype)callControllerWithState:(QMCallState)callState;

@end
