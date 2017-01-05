//
//  QBChatDialog+INPerson.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 1/4/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QBChatDialog+INPerson.h"
#import "NSString+QMTransliterating.h"
#import <Intents/Intents.h>

@implementation QBChatDialog (INPerson)

- (INPerson *)qm_inPerson {
    
    NSString *dialogName = self.name;
    
    if (dialogName.length == 0) {
        return nil;
    }
    
    INPersonHandle *handle = [[INPersonHandle alloc] initWithValue:self.name type:INPersonHandleTypeUnknown];
    NSPersonNameComponents *nameComponents = [[NSPersonNameComponents alloc] init];
    nameComponents.familyName = dialogName;
    
    if (![dialogName canBeConvertedToEncoding:NSISOLatin1StringEncoding]) {
        NSPersonNameComponents *phoneticRepresentation = [[NSPersonNameComponents alloc] init];
        phoneticRepresentation.familyName = [dialogName qm_transliteratedString];
        nameComponents.phoneticRepresentation = phoneticRepresentation;
    }
    
    NSString *displayName = [NSString stringWithFormat:@"chat: %@",dialogName];
    NSString *customIdentifier = [NSString stringWithFormat:@"chat%@",self.ID];
    
    INPerson *person = [[INPerson alloc] initWithPersonHandle:handle
                                               nameComponents:nameComponents
                                                  displayName:displayName
                                                        image:nil
                                            contactIdentifier:nil
                                             customIdentifier:customIdentifier];
    return person;
}

@end
