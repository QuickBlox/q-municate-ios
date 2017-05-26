//
//  DGTDebugConfiguration.h
//
//  Copyright © 2016 Twitter Inc. All rights reserved.
//

#import <DigitsKit/DGTErrors.h>

@class DGTSession;

/**
 *  Overrides for Digits authentication features
 */

@interface DGTDebugConfiguration : NSObject <NSCopying>

- (instancetype)initSuccessStateWithDigitsSession:(DGTSession *)session;

- (instancetype)initErrorStateWithDigitsError:(DGTErrorCode)error;

- (instancetype)init __unavailable;

/**
 *  Returns a stubbed session. Note that this session will not provide valid oauth echo headers. 
 *  If passing this session to a server, note that you'll be unable to query the Digits ouath echo API to lookup account details. 
 *  Be careful to handle this case in your testing (possibly by checking for the stubbed userID value `STUBBED_SESSION`).
 */
+ (DGTSession *)defaultDebugSession;

@end
