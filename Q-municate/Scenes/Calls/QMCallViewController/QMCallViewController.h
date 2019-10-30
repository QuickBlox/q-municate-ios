//
//  QMCallViewController.h
//  Q-municate
//
//  Created by Injoit on 5/10/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

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

// Unavailable initializers
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 *  Call view controller with state.
 *
 *  @param callState specific call view controller state
 *  @param type specific session call type
 *
 *  @see QMCallManager class, QMCallState enum.
 *
 *  @return QMCallViewController with a specific state
 */
+ (instancetype)callControllerWithState:(QMCallState)callState roleState:(QMCallState)roleState;

@end
