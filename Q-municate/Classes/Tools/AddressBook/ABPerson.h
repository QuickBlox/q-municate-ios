//
//  ABPerson.h
//  Qmunicate
//
//  Created by Andrey on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>


@interface ABPerson : NSObject

@property (strong, nonatomic, readonly) NSString *firstName;

- (instancetype)initWithRecordRef:(ABRecordRef)recordRef;

@end
