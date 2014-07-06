//
//  ABPerson.m
//  Qmunicate
//
//  Created by Andrey on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "ABPerson.h"

@interface ABPerson()

@property (assign, nonatomic) ABRecordRef recordRef;

@end

@implementation ABPerson

- (instancetype)initWithRecordRef:(ABRecordRef)recordRef {
    
    self = [super init];
    if (self) {
        _recordRef = CFRetain(recordRef);
    }
    return self;
}

- (void) dealloc
{
    if (self.recordRef)
        CFRelease(_recordRef);
}

- (NSString *)firstName {
    
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(self.recordRef, kABPersonFirstNameProperty);
    return firstName;
}

- (NSString *)lastName {
    
    NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(self.recordRef, kABPersonLastNameProperty);
    return lastName;
}

- (UIImage *)image {
    
    if (!ABPersonHasImageData(self.recordRef)) return nil;
    CFDataRef imageData = ABPersonCopyImageData(self.recordRef);
    if (!imageData) return nil;
    
    NSData *data = (__bridge_transfer NSData *)imageData;
    UIImage *image = [UIImage imageWithData:data];
    
    return image;
}

- (NSArray *)emails {
    
    ABMultiValueRef emails = ABRecordCopyValue(self.recordRef, kABPersonEmailProperty);
    CFIndex capacity = ABMultiValueGetCount(emails);
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:capacity];
    
    for (CFIndex idx = 0; idx < capacity ; idx++) {
        NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, idx);
        [result addObject:email];
    }
    
    CFRelease(emails);
    
    return result;
}

@end
