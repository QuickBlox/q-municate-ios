//
//  DGTAttributionEventDelegate.h
//  DigitsKit
//
//  Copyright © 2016 Twitter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DGTInviteStatus;

@protocol AttributionEventDetails <NSObject>
@end

@protocol DGTAttributionEventDelegate <NSObject>
@optional

/**
 *  Called when we detect a pending invite that is for the current logged in user.
 *  Matches will return an empty array if the current logged in user was not invited
 *  though an invite.
 *
 */
- (void)inviteConversionDetectedWithMatches:(NSArray<DGTInviteStatus *> *)matches;

@end
