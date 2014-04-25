//
//  QMAddressBook.m
//  Q-municate
//
//  Created by Igor Alefirenko on 07/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAddressBook.h"
#import "QMPerson.h"
#import <AddressBook/AddressBook.h>


@implementation QMAddressBook


- (void)getAllContactsFromAddressBook:(AddressBookResult)block
{
    ABAddressBookRef addressBook;
        CFErrorRef error = nil;
        addressBook = ABAddressBookCreateWithOptions(NULL,&error);
    if (addressBook == NULL) {
        ILog(@"%@",error);
        return;
    }
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // callback can occur in background, address book must be accessed on thread it was created on
            if (error) {
                NSString * errorString = [ NSString stringWithFormat:@"QMAddressBook Error: %@", error];
                NSError *error = [NSError errorWithDomain:errorString code:0 userInfo:nil];
                block(nil,NO, error);
                return ;
            }
            NSMutableArray *addressBookContacts = [[NSMutableArray alloc] init];
            
            NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
            NSUInteger i = 0;
            for (i = 0; i < [allContacts count]; i++)
            {
                QMPerson *person = [[QMPerson alloc] init];
                
                ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
                NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
                NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
    
                NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(contactPerson);
                UIImage *avatar = [UIImage imageWithData:imgData];
                
                NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                
                person.firstName = firstName;
                person.lastName = lastName;
                person.fullName = fullName;
                person.avatarImage = avatar;
                person.status = kAddressBookUserStatus;
                
                //email
                ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
                NSUInteger j = 0;
                for (j = 0; j < ABMultiValueGetCount(emails); j++)
                {
                    NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                    if (j == 0)
                    {
                        person.homeEmail = email;
                    }
                    else if (j==1)
                        person.workEmail = email;
                }
                if (person.homeEmail != nil || person.workEmail != nil) {
                    [addressBookContacts addObject:person];
                }
            }

            CFRelease(addressBook);
            block(addressBookContacts, YES, nil);
        });
}

@end
