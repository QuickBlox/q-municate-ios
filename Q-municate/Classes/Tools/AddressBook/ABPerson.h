//
//  ABPerson.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface ABPerson : NSObject

@property (copy, nonatomic, readonly) NSString *firstName;
@property (copy, nonatomic, readonly) NSString *lastName;
@property (copy, nonatomic, readonly) NSString *middleName;
@property (copy, nonatomic, readonly) NSString *nickName;
@property (copy, nonatomic, readonly) UIImage *image;
@property (copy, nonatomic, readonly) NSArray *emails;
@property (copy, nonatomic, readonly) NSString *organizationProperty;
@property (copy, nonatomic, readonly) NSString *fullName;

- (instancetype)initWithRecordID:(ABRecordID)recordID addressBookRef:(ABAddressBookRef)addressBookRef;

@end
