//
//  QMAlphabetizer.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMAlphabetizer.h"

NSString * const QMLAlphabetizerGroupSortNameKey = @"name";
NSString * const QMLAlphabetizerGroupObjectsKey = @"objects";
NSString * const QMLAlphabetizerGroupDisplayNameKey = @"displayName";

@implementation QMAlphabetizer

+ (NSDictionary *)alphabetizedDictionaryFromObjects:(NSArray *)objects usingKeyPath:(NSString *)keyPath {
    
    return [self alphabetizedDictionaryFromObjects:objects
                                      usingKeyPath:keyPath
                          nonAlphabeticPlaceholder:nil];
}

+ (NSMutableArray *)findOrCreateArrayForKey:(NSString *)key
                               inDictionary:(NSMutableDictionary *)dictionary {
    
    NSMutableArray *array = dictionary[key];
    
    if (!array) {
        array = [NSMutableArray array];
        dictionary[key] = array;
    }
    
    return array;
}

+ (NSMutableDictionary *)findOrCreateDictionaryForKey:(NSString *)key
                                         inDictionary:(NSMutableDictionary *)dictionary {
    
    NSMutableDictionary *keyedDictionary = dictionary[key];
    
    if (!keyedDictionary) {
        keyedDictionary = [NSMutableDictionary dictionary];
        dictionary[key] = keyedDictionary;
    }
    
    return keyedDictionary;
}

+ (NSString *)keyFromObject:(id)object
               usingKeyPath:(NSString *)keyPath
                     result:(NSString **)keyPathResult
                placeholder:(NSString *)placeholder
                  maxLength:(NSUInteger)maxLength
          validCharacterSet:(NSCharacterSet *)validCharacterSet {
    
    NSString *result = placeholder;
    NSString *key = placeholder;
    
    if ([object respondsToSelector:NSSelectorFromString(keyPath)] || [object isKindOfClass:[NSDictionary class]]) {
        
        id possibleKey = [object valueForKeyPath:keyPath];
        
        if ([possibleKey isKindOfClass:[NSString class]] && [possibleKey length]) {
            
            result = possibleKey;
            key = possibleKey;
            
            if (maxLength > 0 && [key length] > maxLength) {
                
                key = [key substringToIndex:maxLength];
            }
            
            NSString *ignorableBeginning = [self ignorableBeginningWordFromString:key];
            
            if ([ignorableBeginning length]) {
                
                key = [[key substringFromIndex:[ignorableBeginning length]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ;
                key = [key stringByAppendingFormat:@", %@", ignorableBeginning];
            }
            
            if (validCharacterSet) {
                
                NSCharacterSet *keyCharacterSet = [NSCharacterSet characterSetWithCharactersInString:key];
                
                if (![validCharacterSet isSupersetOfSet:keyCharacterSet]) {
                    key = placeholder;
                }
            }
        }
    }
    
    if (keyPathResult) {
        *keyPathResult = result;
    }
    
    return key;
}

+ (NSString *)ignorableBeginningWordFromString:(NSString *)string {
    
    NSArray *ignorableWords = @[@"A ", @"The "];
    
    for (NSString *ignorable in ignorableWords) {
        
        if ([string rangeOfString:ignorable].location == 0) {
            return ignorable;
        }
    }
    
    return nil;
}

+ (NSDictionary *)groupedDictionaryFromObjects:(NSArray *)objects
                                  usingKeyPath:(NSString *)keyPath
                                        sortBy:(NSString *)sortableKeyPath
                      nonAlphabeticPlaceholder:(NSString *)placeholder {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSString *nonLetterPlaceholder = [placeholder length] ? placeholder : @"#";
    
    for (id object in objects) {
        NSString *name;
        NSString *key = [self keyFromObject:object
                               usingKeyPath:keyPath
                                     result:&name
                                placeholder:nonLetterPlaceholder
                                  maxLength:0
                          validCharacterSet:nil];
        
        NSMutableDictionary *keyedDictionary = [self findOrCreateDictionaryForKey:[key uppercaseString]
                                                                     inDictionary:dictionary];
        
        NSMutableArray *array = [self findOrCreateArrayForKey:QMLAlphabetizerGroupObjectsKey inDictionary:keyedDictionary];
        keyedDictionary[QMLAlphabetizerGroupSortNameKey] = key;
        keyedDictionary[QMLAlphabetizerGroupDisplayNameKey] = name;
        
        [array addObject:object];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortableKeyPath
                                                                   ascending:YES];
    
    for (NSString *key in dictionary) {
        
        [dictionary[key][QMLAlphabetizerGroupObjectsKey] sortUsingDescriptors:@[sortDescriptor]];
    }
    
    return [self alphabetizedDictionaryFromObjects:[dictionary allValues]
                                      usingKeyPath:QMLAlphabetizerGroupSortNameKey
                          nonAlphabeticPlaceholder:placeholder];
}

+ (NSDictionary *)alphabetizedDictionaryFromObjects:(NSArray *)objects
                                       usingKeyPath:(NSString *)keyPath
                           nonAlphabeticPlaceholder:(NSString *)placeholder {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSString *nonLetterPlaceholder = [placeholder length] ? placeholder : @"#";
    
    for (id object in objects) {
        
        NSString *firstLetter = [self keyFromObject:object
                                       usingKeyPath:keyPath
                                             result:nil
                                        placeholder:nonLetterPlaceholder
                                          maxLength:1
                                  validCharacterSet:[NSCharacterSet letterCharacterSet]];
        
        firstLetter = [firstLetter uppercaseString];
        NSMutableArray *array = [self findOrCreateArrayForKey:firstLetter inDictionary:dictionary];
        [array addObject:object];
    }
    
    // now sort all the arrays
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:keyPath ascending:YES];
    
    for (NSString *key in dictionary) {
        
        [dictionary[key] sortUsingDescriptors:@[sortDescriptor]];
    }
    
    return dictionary;
}

+ (NSArray *)indexTitlesFromAlphabetizedDictionary:(NSDictionary *)alphabetizedDictionary {
    
    return [[alphabetizedDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

@end
