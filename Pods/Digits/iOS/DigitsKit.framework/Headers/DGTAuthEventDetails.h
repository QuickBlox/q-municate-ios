//
//  DGTAuthEventDetails.h
//  DigitsKit
//
//  Created by Joey Carmello on 5/19/16.
//  Copyright © 2016 Twitter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DGTAuthEventDetails : NSObject

// How long has passed since the initial event in the authentication flow
@property (assign, nonatomic, readonly) NSTimeInterval elapsedTime;

// The language from the locale of the device
@property (strong, nonatomic, readonly) NSString *language;

// The country derived from the phone number provided
@property (strong, nonatomic, readonly, nullable) NSString *countryISOCode;

- (instancetype)init __unavailable;

@end

NS_ASSUME_NONNULL_END
