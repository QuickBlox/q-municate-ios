//
//  DGTInviteStatus.h
//  DigitsKit
//
//  Copyright © 2016 Twitter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Defines all the possible states that an invite can be in.
 *
 *  DGTInviteStateConverted - The recipient of the invite has received and accepted the invite.
 *  DGTInviteStatePending - The receipient of the invite has not accepted the invite.
 */
typedef NS_ENUM(NSInteger, DGTInviteState) {
    DGTInviteStateConverted = 0,
    DGTInviteStatePending = 1,
};

@interface DGTInviteStatus : NSObject

/**
 *  The application identifier of the application that made invite.
 */
@property (nonatomic, copy) NSString *appID;

/**
 *  The date the invite was sent.
 */
@property (nonatomic, copy) NSDate *inviteLastSent;

/**
 *  The phone number of the recipient of the invite.
 */
@property (nonatomic, copy) NSString *phoneNumber;

/**
 *  The identifier of the original person who sent the invite.
 */
@property (nonatomic, copy) NSString *inviterID;

/**
 *  The identifier of the recipient of the invite.
 */
@property (nonatomic, copy) NSString *friendID;

/**
 *  The date the invite was accepted.
 */
@property (nonatomic, copy) NSDate *convertedTime;

/**
 *  The current state of the invite.
 */
@property (nonatomic) DGTInviteState inviteState;

@end
