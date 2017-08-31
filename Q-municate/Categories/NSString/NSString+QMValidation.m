//
//  NSString+QMValidation.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 8/25/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "NSString+QMValidation.h"
#import "QMErrorsFactory.h"

static NSString *const kQMEmailRegex = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";


@implementation NSString (QMValidation)

- (BOOL)qm_validateForNotAcceptableCharacters:(NSString *)notAcceptableCharacters
                                        error:(NSError **)error {
    
    NSCharacterSet *notAcceptableCharactersSet = [NSCharacterSet characterSetWithCharactersInString:notAcceptableCharacters];
    NSString *filtered = [[self componentsSeparatedByCharactersInSet:notAcceptableCharactersSet] componentsJoinedByString:@""];
    
    if (![filtered isEqualToString:self]) {
        
        NSMutableString *result = [NSMutableString new];
        
        for (NSUInteger i = 0; i < notAcceptableCharacters.length; i++) {
            
            unichar c = [notAcceptableCharacters characterAtIndex:i];
            if (i == 0) {
                [result appendFormat:@"%C",c];
            }
            else {
                [result appendFormat:@" %C",c];
            }
        }
        
        NSString *errorDescription = nil;
        if (notAcceptableCharacters.length == 1) {
            errorDescription =
            [NSString stringWithFormat:NSLocalizedString(@"QM_STR_VALIDATION_ERROR_NOT_ALLOWED_CHARACTER_SINGLE", @"{Character}"), result.copy];
        }
        else {
            errorDescription =
            [NSString stringWithFormat:NSLocalizedString(@"QM_STR_VALIDATION_ERROR_NOT_ALLOWED_CHARACTER_PLURAL", @"{Characters}"), result.copy];
        }
        
        *error = [QMErrorsFactory validationErrorWithLocalizedDescription:errorDescription];
        
        return NO;
    }
    
    return YES;
}
- (BOOL)qm_validateForCharactersCountWithMinLength:(NSUInteger)minLength
                                         maxLength:(NSUInteger)maxLength
                                             error:(NSError **)error {
    
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
    NSUInteger textLength = [self stringByTrimmingCharactersInSet:whiteSpaceSet].length;
    
    if (minLength > 0 && textLength < minLength) {
        
        NSString *validationErrorDescription =
        [NSString stringWithFormat:NSLocalizedString(@"QM_STR_VALIDATION_ERROR_LENGTH_MIN", @"{Number of symbols}"), minLength];
        *error = [QMErrorsFactory validationErrorWithLocalizedDescription:validationErrorDescription];
        
        return NO;
    }
    
    if (maxLength > 0 && textLength > maxLength) {
        NSString *validationErrorDescription =
        [NSString stringWithFormat:NSLocalizedString(@"QM_STR_VALIDATION_ERROR_LENGTH_MAX",@"{Number of symbols}"), maxLength];
        *error = [QMErrorsFactory validationErrorWithLocalizedDescription:validationErrorDescription];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)qm_validateForEmailFormat:(NSError **)error {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kQMEmailRegex];
    
    if (![predicate evaluateWithObject:self]) {
        NSString *validationErrorDescription = NSLocalizedString(@"QM_STR_VALIDATION_ERROR_EMAIL",nil);
        *error =  [QMErrorsFactory validationErrorWithLocalizedDescription:validationErrorDescription];
        
        return NO;
    }
    
   return YES;
}

@end
