//
//  DGTInvites.h
//  DigitsKit
//
//  Copyright © 2016 Twitter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Digits;
@class DGTInviteFlowConfiguration;

/**
 *  Block type called after users exit from the invitation flow started from
 *  startInvitationFlowWithPresenterViewController API call
 *
 *  error is non-nil in case the flow can not be started (for example being denied to read from address book).
 */
typedef void (^DGTInvitationFlowCompletion)(NSError *error);

@protocol DGTContactsPickerActionEventDelegate <NSObject>
@optional

/**
 *  Called when the user finishes the action of sending the sms invite message to a contact.
 *
 *  contactName is the display name of that contact entry from the address book
 *  phoneNumber is the target phone number the invite sms is sent to.
 */
- (void)inviteSMSSentToContact:(NSString *)contactName withPhoneNumber:(NSString *)phoneNumber;
@end


@interface DGTInvites : NSObject

/**
 *  Creates an instance of DGTInvites.
 */
- (instancetype)init;

/**
 *  Entrance point for starting the whole invitation flow with default UI. The invitation flow is presented above
 *  the passed presenterViewController and provides an interface for inviting contacts through SMS. If the user
 *  does not have a valid Digits Session, invites are not tracked on Digits service side and Answers events will 
 *  not be logged.
 *
 *  @param presenterViewController a view controller from where the invitation view controller will be presented.
 *          If it's nil, the App's root view controller will be used as the presenting view controller
 *  @param configuration Configurations that be used to tune settings for the invitation flow. Check DGTInviteFlowConfiguration
 *           for detailed setting configurations there. It's required
 *  @param userActionNotifyDelegate optional. A delegate for app to get notified after an invite text has sent by the user.
 *  @param flowCompletion optional. Completion callback when the user exits the flow UI
 */
- (void)startInvitationFlowWithPresenterViewController:(UIViewController *)presenterViewController
                                     withConfiguration:(DGTInviteFlowConfiguration *)configuration
                          withUserActionNotifyDelegate:(id<DGTContactsPickerActionEventDelegate>)userActionNotifyDelegate
                                    withFlowCompletion:(DGTInvitationFlowCompletion)flowCompletion;

@end
