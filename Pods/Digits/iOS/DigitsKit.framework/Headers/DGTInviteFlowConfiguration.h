//
//  DGTInviteFlowConfiguration.h
//  DigitsKit
//
//  Created by Yong Mao on 9/12/16.
//  Copyright © 2016 Twitter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DGTAddressBookContact;
@class DGTBranchConfiguration;

typedef NS_ENUM(NSInteger, DGTInAppButtonState) {
    DGTInAppButtonStateNormal = 0,
    DGTInAppButtonStateActive = 1
};

NS_ASSUME_NONNULL_BEGIN

typedef void (^DGTInAppInviteUserAction)(NSString *phoneNumber, NSString *digitsID, DGTInAppButtonState state);
typedef NSString* _Nonnull (^DGTSMSTextBlock)(DGTAddressBookContact *contact,  NSString * _Nullable inviteUrl);

@interface DGTInviteFlowConfiguration : NSObject

/**
 *  Determines the prefill text of the sms that is sent when the MFMessageComposeViewController
 *  is presented. The DGTSMSTextBlock takes two parameters: a DGTAddressBookContact and an
 *  invite URL. The return type of the block is an NSString. The invite URL will be nil unless
 *  the Branch framework is integrated into your project and the branchConfig parameter is also
 *  set. The default implementation of the DGTGSMSBlock is a localized string that accomodates
 *  for the case where the invite URL is nil.
 */
@property (nonatomic, copy, readonly) DGTSMSTextBlock smsPrefillText;

/**
 *  Override this for customizing the app's display name. The default value would be the bundle display name
 *  detected for the current app.
 */
@property (nonatomic, copy, readonly) NSString *appDisplayName;

/** 
 *  Override it to specify the title text showing up on the navigation bar on invite view
 *  default: 'Invite Friends'
 */
@property (nonatomic, copy, readonly) NSString *inviteViewTitle;


/**
 *  This is used when being integrated with branch. When it's set, Digits will detect the existence of Branch
 *  at runtime and use it, with the configurations specified in this field, to helpe generate branch links to be used
 *  for invite sms text.
 */
@property (nonatomic, copy, readonly) DGTBranchConfiguration *branchConfig;

/**
 *  Here we have a number of init methods for constructing DGTInviteFlowConfiguration instances. Each of them
 *  allow you to customize certain things, each of which corresponds to one of the properties defined above. Pick
 *  the initializer that covers the things you want to override.
 *
 *  If any of them is not specified in the parameter or set to be nil, its default value will be used at runtime.
 *  Check comments for each property to see what's the default value.
 *
 *  Once DGTInviteFlowConfiguration object is instiantiated, the above properties will become readonly: their value is
 *  either the one that's specified in initializer parameters or filled up with default values.
 */
- (instancetype)init;

/**
 * Construct a configuration with custom text generation block
 */
- (instancetype)initWithPrefillTextBlock:(nullable DGTSMSTextBlock)prefillTextBlock;

/**
 * Construct a configuration with custom app name, view title and/or text generation block
 */
- (instancetype)initWithAppDisplayName:(nullable NSString *)appDisplayName
                     withViewTitleText:(nullable NSString *)viewTitle
                  withPrefillTextBlock:(nullable DGTSMSTextBlock)prefillTextBlock;

/**
 * Construct a configuration with custom app name, view title, branch integration config, and/or text generation block
 */
- (instancetype)initWithAppDisplayName:(nullable NSString *)appDisplayName
                     withViewTitleText:(nullable NSString *)viewTitle
    withBranchIntegrationConfiguration:(nullable DGTBranchConfiguration *)branchConfig
                  withPrefillTextBlock:(nullable DGTSMSTextBlock)prefillTextBlock;

@end

NS_ASSUME_NONNULL_END
