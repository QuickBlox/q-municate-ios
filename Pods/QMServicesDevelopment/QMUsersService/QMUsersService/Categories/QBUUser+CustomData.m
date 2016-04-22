//
//  QBUUser+CustomData.m
//  QMServices
//
//  Created by Andrey Ivanov on 27.04.15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QBUUser+CustomData.h"
#import <objc/runtime.h>

NSString *const kQMAvatarUrlKey = @"avatar_url";
NSString *const kQMStatusKey = @"status";
NSString *const kQMIsImportKey = @"is_import";
NSString *const kQMIsSearchableKey = @"is_searchable";

@interface QBUUser (QMAssociatedObject)

@property (strong, nonatomic) NSMutableDictionary *context;

@end

@implementation QBUUser (QMAssociatedObject)

@dynamic context;

- (NSMutableDictionary *)context {
    
    NSMutableDictionary *context = objc_getAssociatedObject(self, @selector(context));
    
    if (!context) {
        
        context = self.jsonObject;
        [self setContext:context];
    }
    
    return context;
}

- (void)setContext:(NSMutableDictionary *)context {
    
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)jsonObject {
    
    NSError *error = nil;
    NSData *jsonData = [self.customData dataUsingEncoding:NSUTF8StringEncoding];
    
    if (jsonData) {
        
        NSDictionary *representationObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
        return representationObject.mutableCopy;
    }
    else {
        
        return @{}.mutableCopy;
    }
}

- (void)syncronize {
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.context
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    self.customData = [[NSString alloc] initWithData:jsonData
                                            encoding:NSUTF8StringEncoding];
}

@end

@implementation QBUUser (CustomData)

@dynamic avatarUrl;
@dynamic status;
@dynamic isImport;
@dynamic isSearchable;

#pragma mark - Is import

- (void)setIsImport:(BOOL)isImport {
    
    self.context[kQMIsImportKey] = @(isImport);
    [self syncronize];
}

- (BOOL)isImport {
    
    NSNumber *isImprot = self.context[kQMIsImportKey];
    return isImprot.boolValue;
}

#pragma mark - Is searchable

- (void)setIsSearchable:(BOOL)isSearchable
{
  self.context[kQMIsSearchableKey] = @(isSearchable);
  [self syncronize];
}

- (BOOL)isSearchable
{
  NSNumber *isSearchable = self.context[kQMIsSearchableKey];
  if (isSearchable == nil)
    return YES;
  return isSearchable.boolValue;
}

#pragma mark - Status

- (void)setStatus:(NSString *)status {
    
    self.context[kQMStatusKey] = status;
    [self syncronize];
}

- (NSString *)status {
    
    return self.context[kQMStatusKey];
}

#pragma mark - Avatar url

- (void)setAvatarUrl:(NSString *)avatarUrl {
    
    self.context[kQMAvatarUrlKey] = avatarUrl;
    [self syncronize];
}

- (NSString *)avatarUrl {
    
    return self.context[kQMAvatarUrlKey];
}

@end
