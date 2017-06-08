//
//  DGTAddressBookContact.h
//  DigitsKit
//
//  Created by Yong Mao on 8/11/16.
//  Copyright © 2016 Twitter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// The data model for a single contact used in friends invitation flow
@interface DGTAddressBookContact : NSObject
NS_ASSUME_NONNULL_BEGIN

/**
 *  String containing the name of the contact as it is seen in the address book.
 */
@property (nonatomic, readonly, copy) NSString * displayName;

/**
 *  Phone number of the user as seen in the iOS address book.
 */
@property (nonatomic, readonly, copy) NSString * phoneNumberFromAddressBook;

/**
 *  The phone number with the non-digits characters stripped out. The phone number normalized per E.164.
 */
@property (nonatomic, readonly, copy) NSString * normalizedPhoneNumber;

/**
 * User ID of the contact from the digits API. This field will be nil if the contact is not on digits.
 */
@property (nonatomic, copy, nullable) NSString *userID;

/**
 *  A flag to indicate if this contact entry has been invited by the current user or not
 */
@property (nonatomic) BOOL invited;

/**
 *  Initializes an instance of DGTAddressBook Contact with a display name and phone number.
 * */
- (instancetype)initWithName:(NSString *)displayName
       numberFromAddressBook:(NSString *)phoneNumber;

/**
 *  Unavailable. Use initWithName:numberFromAddressBook: instead.
 */
- (instancetype)init __unavailable;

NS_ASSUME_NONNULL_END
@end



