//
//  QBUpdateUserParameters+CustomParameters.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/22/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QBUpdateUserParameters+CustomParameters.h"
#import <objc/runtime.h>

static NSString *const QBAvatarURLKey = @"avatar_url";
static NSString *const QBStatusKey = @"status";
static NSString *const QBIsImportedKey = @"is_import";
static const char statustKey;
static const char avatarUrlKey;


@implementation QBUpdateUserParameters (CustomParameters)


#pragma mark - Setters & getters

- (void)setAvatarURL:(NSString *)avatarURL
{
    objc_setAssociatedObject(self, &avatarUrlKey, avatarURL, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setString:avatarURL forKey:QBAvatarURLKey];
}

- (NSString *)avatarURL
{
    NSString *avatatURL = objc_getAssociatedObject(self, &avatarUrlKey);
    if (avatatURL == nil) {
        avatatURL = [self stringForKey:QBAvatarURLKey];
        if (avatatURL) {
            objc_setAssociatedObject(self, &avatarUrlKey, avatatURL, OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
    }
    return avatatURL;
}

- (void)setStatus:(NSString *)status
{
    objc_setAssociatedObject(self, &statustKey, status, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setString:status forKey:QBStatusKey];
}

-(NSString *)status
{
    NSString *statusString = objc_getAssociatedObject(self, &statustKey);
    if (statusString == nil) {
        statusString = [self stringForKey:QBStatusKey];
        if (statusString) {
            objc_setAssociatedObject(self, &statustKey, statusString, OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
    }
    return statusString;
}

- (void)setImported:(BOOL)imported
{
    NSString *importedKeyString = [NSString stringWithFormat:@"%hhd", imported];
    [self setString:importedKeyString forKey:QBIsImportedKey];
}

- (BOOL)imported
{
    NSString *importedKeyString = [self stringForKey:QBIsImportedKey];
    return [importedKeyString boolValue];
}


#pragma mark - Serialization

- (void)setString:(NSString *)string forKey:(NSString *)key
{
    NSMutableDictionary *jsonDict = [self dictionaryFromString:self.customData];
    // returned dictionary - existed or new:
    if (string) {
        jsonDict[key] = string;
    } else {
        [jsonDict removeObjectForKey:key];
    }
    NSString *jsonString = [self stringFromDictionary:jsonDict];
    self.customData = jsonString;
}

- (NSString *)stringForKey:(NSString *)key
{
    NSString *string = nil;
    NSMutableDictionary *jsonDict = [self dictionaryFromString:self.customData];
    if (jsonDict != nil) {
        string = jsonDict[key];
    }
    return string;
}

#pragma mark -

- (NSString *)stringFromDictionary:(NSMutableDictionary *)dict
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSMutableDictionary *)dictionaryFromString:(NSString *)string
{
    NSMutableDictionary *customParams = nil;
    NSError *error = nil;
    
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData == nil) {
        return [[NSMutableDictionary alloc] init];
    }
    customParams = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error] mutableCopy];
    if (customParams == nil) {
        customParams = [[NSMutableDictionary alloc] init];
    }
    return customParams;
}

@end
