//
//  QBUUser+CustomData.m
//  QMServices
//
//  Created by Andrey Ivanov on 27.04.15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QBUUser+CustomData.h"
#import <objc/runtime.h>
#import "QMSLog.h"

NSString *const kQMAvatarUrlKey = @"avatar_url";
NSString *const kQMStatusKey = @"status";
NSString *const kQMIsImportKey = @"is_import";

@implementation QBUUser (QMAssociatedObject)

- (NSMutableDictionary *)context {
    
    NSMutableDictionary *context = objc_getAssociatedObject(self, @selector(context));
    
    if (!context) {
        
        context = self.jsonObject;
        objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return context;
}

- (NSMutableDictionary *)jsonObject {
    
    NSError *error = nil;
    NSData *jsonData = [self.customData dataUsingEncoding:NSUTF8StringEncoding];
    
    if (jsonData) {
        
        NSDictionary *representationObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:0
                                                                               error:&error];
        
        if (error != nil) {
            
            QMSLog(@"Error serializing data to JSON: %@", error);
            return [[NSMutableDictionary alloc] init];
        }
        
        NSMutableDictionary *mutableObject = [representationObject mutableCopy];
        
        // removing possible null values
        [representationObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * __unused stop) {
            
            if (obj == [NSNull null]) {
                
                [mutableObject removeObjectForKey:key];
            }
        }];
        
        return mutableObject;
    }
    else {
        
        return [[NSMutableDictionary alloc] init];
    }
}

- (void)synchronize {
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.context
                                                       options:0
                                                         error:&error];
    
    if (error != nil) {
        
        QMSLog(@"Error serializing JSON to data: %@", error);
        return;
    }
    
    self.customData = [[NSString alloc] initWithData:jsonData
                                            encoding:NSUTF8StringEncoding];
}

@end

@implementation QBUUser (CustomData)

@dynamic avatarUrl;
@dynamic status;
@dynamic isImport;

//MARK: - Is import

- (void)setIsImport:(BOOL)isImport {
    
    self.context[kQMIsImportKey] = @(isImport);
    [self synchronize];
}

- (BOOL)isImport {
    
    NSNumber *isImprot = self.context[kQMIsImportKey];
    return isImprot.boolValue;
}

//MARK: - Status

- (void)setStatus:(NSString *)status {
    
    self.context[kQMStatusKey] = [status copy];
    [self synchronize];
}

- (NSString *)status {
    
    return self.context[kQMStatusKey];
}

//MARK: - Avatar url

- (void)setAvatarUrl:(NSString *)avatarUrl {
    
    self.context[kQMAvatarUrlKey] = [avatarUrl copy];
    [self synchronize];
}

- (NSString *)avatarUrl {
    
    return self.context[kQMAvatarUrlKey];
}

@end
