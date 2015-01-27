//
//  QMAddressBook.h
//  Q-municate
//
//  Created by Igor Alefirenko on 07/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AddressBookResult)(NSArray *contacts, BOOL success, NSError *error);

@interface QMAddressBook : NSObject

+ (void)getAllContactsFromAddressBook:(AddressBookResult)block;
+ (void)getContactsWithEmailsWithCompletionBlock:(AddressBookResult)block;

@end
