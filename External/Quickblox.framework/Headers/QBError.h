//
//  QBError.h
//  Quickblox
//
//  Created by QuickBlox team on 8/18/14.
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBError : NSObject

@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *reasons;
@property (nonatomic, readonly, nullable) NSError *error;

+ (instancetype)errorWithError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
