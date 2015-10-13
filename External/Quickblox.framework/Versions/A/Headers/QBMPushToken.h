//
//  QBMPushToken.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "QBCEntity.h"

/** QBMPushToken class declaration. */
/** Overview */
/** Class represents push token, that uniquely identifies the application.  (for APNS - it's token, for C2DM - it's registration Id, for MPNS - it's uri, for BBPS - it's token). */

@interface QBMPushToken : QBCEntity <NSCoding, NSCopying>{
	NSString *clientIdentificationSequence;
	BOOL isProductionEnvironment;
}

/** Identifies client device in 3-rd party service like APNS, C2DM, MPNS, BBPS.*/
@property(nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *clientIdentificationSequence;

/** Set custom UDID or use auto-generated UDID if customUDID is nil */
@property(nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *customUDID;

/** Determine application mode. It allows conveniently separate development and production modes, default: YES
 
 @warning Deprecated in 2.4.4. See '[QBApplication sharedApplication].autoDetectEnvironment'.
 */
@property (nonatomic) BOOL isProductionEnvironment DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.4.4. There is no need to set this property manually if you are using automatic environment detection.");

/** Create new push token
 @return New instance of QBMPushToken
 */
+ (QB_NONNULL QBMPushToken *)pushToken;

/** Create new push token
 @return New instance of QBMPushToken with custom UDID
 */
+ (QB_NONNULL QBMPushToken *)pushTokenWithCustomUDID:(QB_NULLABLE NSString *)customUDID;

@end