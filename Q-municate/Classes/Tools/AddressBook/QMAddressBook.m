//
//  QMAddressBook.m
//  Q-municate
//
//  Created by Igor Alefirenko on 07/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAddressBook.h"
#import <AddressBook/AddressBook.h>
#import "ABPerson.h"

@implementation QMAddressBook

+ (void)getAllContactsFromAddressBook:(AddressBookResult)block {

    CFErrorRef error = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBook == NULL) {
        
		block(nil, NO, (__bridge NSError *)error);
        
    } else {
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef cfError) {
            // callback can occur in background, address book must be accessed on thread it was created on
            if (error || !granted) {
                
                NSError *requestError = (__bridge NSError *)cfError;
                block(nil, NO, requestError);
                
            } else {
                
                CFIndex contactsCount = ABAddressBookGetPersonCount(addressBook);
                NSMutableArray *persons = [NSMutableArray arrayWithCapacity:contactsCount];
                if (contactsCount > 0) {
                    
                    CFArrayRef peoples = ABAddressBookCopyArrayOfAllPeople(addressBook);
                   
                    for (CFIndex i = 0; i < contactsCount; i++) {
                        
                        ABRecordRef ref = CFArrayGetValueAtIndex(peoples, i);

                        ABRecordID contactID = ABRecordGetRecordID(ref);
                        
                        ABPerson *person = [[ABPerson alloc] initWithRecordID:contactID addressBookRef:addressBook];
                        [persons addObject:person];
                    }
                    CFRelease(peoples);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(persons, YES, nil);
                });
            }
            CFRelease(addressBook);
        });
    }
}

+ (void)getContactsWithEmailsWithCompletionBlock:(void(^)(NSArray *contactsWithEmails))block
{
    [QMAddressBook getAllContactsFromAddressBook:^(NSArray *contacts, BOOL success, NSError *error) {
        if (success) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.emails.@count > 0"];
            NSArray *contactsWithEmails = [contacts filteredArrayUsingPredicate:predicate];
            NSArray *filteredContacts = [[self class] filteredArrayForDuplicatesFromArray:contactsWithEmails];

            if (filteredContacts == nil) {
                filteredContacts = @[];
            }
            block(filteredContacts);
            return;
        }
        block(@[]);
    }];
}

+ (NSArray *)filteredArrayForDuplicatesFromArray:(NSArray *)array
{
    NSMutableArray *newArray = [NSMutableArray new];
    for (ABPerson *person in array) {
        if (![newArray containsObject:person]) {
            [newArray addObject:person];
        }
    }
    return [newArray copy];
}

@end
