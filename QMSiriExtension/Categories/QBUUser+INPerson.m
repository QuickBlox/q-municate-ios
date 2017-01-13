//
//  QBUUser+INPerson.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 1/4/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QBUUser+INPerson.h"
#import <Intents/Intents.h>
#import "NSString+QMTransliterating.h"

@implementation QBUUser (INPerson)

- (INPerson *)qm_inPerson {
    
    INPersonHandle *handle = [[INPersonHandle alloc] initWithValue:self.login type:INPersonHandleTypeUnknown];
    NSPersonNameComponents *nameComponents = [[NSPersonNameComponents alloc] init];
    nameComponents.familyName = self.fullName;
    
    if (![self.fullName canBeConvertedToEncoding:NSISOLatin1StringEncoding]) {
        
        NSPersonNameComponents *phoneticRepresentation = [[NSPersonNameComponents alloc] init];
        phoneticRepresentation.familyName = [self.fullName qm_transliteratedString];
        nameComponents.phoneticRepresentation = phoneticRepresentation;
    }
    
    NSString *customIdentifier = [NSString stringWithFormat:@"%lu",(unsigned long)self.ID];
    
    INPerson *person = [[INPerson alloc] initWithPersonHandle:handle
                                               nameComponents:nameComponents
                                                  displayName:self.fullName
                                                        image:nil
                                            contactIdentifier:nil
                                             customIdentifier:customIdentifier];
    return person;
}

@end
