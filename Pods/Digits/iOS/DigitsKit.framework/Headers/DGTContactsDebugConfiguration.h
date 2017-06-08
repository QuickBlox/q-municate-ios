//
//  DGTContactsDebugConfiguration.h
//  DigitsKit
//
//  Copyright © 2016 Twitter Inc. All rights reserved.
//

#import <DigitsKit/DGTErrors.h>

@class DGTUser;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Overrides for Digits contacts features
 */
@interface DGTContactsDebugConfiguration : NSObject <NSCopying>

- (instancetype)initSuccessStateWithContacts:(NSArray<DGTUser *> *)contacts;

- (instancetype)initErrorStateWithDigitsError:(DGTErrorCode)error;

- (instancetype)init __unavailable;

+ (NSArray<DGTUser *> *)stubbedContactsWithDigitsUserIDs:(NSArray<NSString *> *)digitsUserIDs;

@end

NS_ASSUME_NONNULL_END
