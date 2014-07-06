//
//  QMAddressBook.h
//  Q-municate
//
//  Created by Igor Alefirenko on 07/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QMAddressBook : NSObject

- (void)getAllContactsFromAddressBook:(AddressBookResult)block;

@end
