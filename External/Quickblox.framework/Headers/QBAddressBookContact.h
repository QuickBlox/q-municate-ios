//
//  QBAddressBookContact.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 QBAddressBookContact class interface.
 This class represents a user's address book item.
 */
@interface QBAddressBookContact : NSObject <NSCoding, NSCopying>

/** The name of address book contact item (required only for create/update), min 1 max 255 symbols */
 @property (nonatomic, copy) NSString *name;
 
 /** The phone number of address book contact item (required), min 10 max 15 symbols */
 @property (nonatomic, copy) NSString *phone;
 
 /** The flag to destroy the address book contact item (not required, possible value YES) */
 @property (nonatomic) BOOL destroy;
 
 @end
 
 NS_ASSUME_NONNULL_END
