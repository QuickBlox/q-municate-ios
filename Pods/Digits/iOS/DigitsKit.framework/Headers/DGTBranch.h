//
//  DGTBranch.h
//  DigitsKit
//
//  Copyright © 2016 Twitter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DGTBranchConfiguration;
@class Digits;
@class Branch;

NS_ASSUME_NONNULL_BEGIN

@interface DGTBranch : NSObject

/**
 *  A wrapper method for Branch's initSessionWithLaunchOptions:andRegisterDeepLinkHandler. This is to be
 *  used if you want Digits to log the answers event "Digits-Branch-Invite-Recipient-Launched-App" automatically.
 *
 *  @param digits (required) - A valid Digits instance.
 *  @param branch (required) - A valid Branch instance.
 *  @param options (required) - Launch options from application:didFinishLaunchingWithOptions:
 *  @param callback (optional) - A callback that is called when the session is opened. This will be called multiple 
 *  times during the apps life, including any time the app goes through a background / foreground cycle. This callback
 *  is the exact same as the callback as the one in initSessionWithLaunchOptions:andRegisterDeepLinkHandler.
 */
+ (void)initSessionWithDigits:(Digits *)digits
                   withBranch:(Branch *)branch
            withLaunchOptions:(NSDictionary * _Nullable )options
   andRegisterDeepLinkHandler:(nullable void(^)(NSDictionary * _Nonnull params, NSError * _Nullable error))callback;

@end

NS_ASSUME_NONNULL_END
