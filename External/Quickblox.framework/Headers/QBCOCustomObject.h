//
//  QBCOCustomObject.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBCOPermissions;

NS_ASSUME_NONNULL_BEGIN

/** 
 `QBCOCustomObject` class interface.
 This class represents QuickBlox custom object model.
 
 @see https://quickblox.com/developers/Custom_Objects#Module_description
 */
@interface QBCOCustomObject : NSObject <NSCoding, NSCopying>

/** 
 The id of custom object.
 */
@property (nonatomic, copy, nullable) NSString *ID;

/** 
 The Relations: parent object's ID.
 */
@property (nonatomic, copy, nullable) NSString *parentID;

/** 
 The Date & time when record was created.
 */
@property (nonatomic, strong, nullable) NSDate *createdAt;

/** 
 The Date & time when record was updated
 */
@property (nonatomic, strong, nullable) NSDate *updatedAt;

/** 
 The class name of the custom object.
 */
@property (nonatomic, copy, nullable) NSString *className;

/** 
 The id of User, which created the current record.
 */
@property (nonatomic, assign) NSUInteger userID;

/** 
 The Custom object's fields.
 */
@property (nonatomic, strong, null_resettable) NSMutableDictionary <NSString *, id> *fields;

/** 
 The permissions of the custom object.
 */
@property (nonatomic, strong, nullable) QBCOPermissions *permissions;

/** 
 Create new custom object.
 
 @return New instance of QBCOCustomObject.
 */
+ (instancetype)customObject;

/**
 Create new custom object with class name

 @param className The class name of the custom object.
 @return New instance of QBCOCustomObject.
 */
+ (instancetype)objectWithClassName:(NSString *)className;

//MARK: Keyed subscripting for fields

/**
 Keyed subscripting for fields
 
 How to use:
 
     QBCOCustomObject *obj = [QBCOCustomObject objectWithClassName:@"Movie"];
     obj[@"name"] = @"Terminator";
     obj[@"description"] = @"Best movie ever!";
     obj[@"raiting"] = @"5";
 */
- (nullable id)objectForKeyedSubscript:(NSString *)key;

/** Keyed subscripting for fields */
- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
