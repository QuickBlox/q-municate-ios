//
//  QBUUser+CustomParameters.m
//  Q-municate
//
//  Created by Igor Alefirenko on 29.09.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QBUUser+CustomParameters.h"
#import <objc/runtime.h>

NSString *const QBAvatarURLKey = @"avatar_url";
NSString *const QBStatusKey = @"status";
NSString *const QBIsImportedKey = @"is_import";

@interface QBUUser (CustomParametersConterxt)

@property (strong, nonatomic) NSMutableDictionary *context;

@end

@implementation QBUUser (CustomParameters)

#pragma mark - Setters & getters

- (void)setContext:(NSMutableDictionary *)object {
    
    objc_setAssociatedObject(self, @selector(context), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)context {
    
    NSMutableDictionary *context = objc_getAssociatedObject(self, @selector(context));
    
    if (!context) {
        
        NSMutableDictionary *jsonObject = self.jsonObject;
        self.context = jsonObject;
        context = jsonObject;
    }
    
    return context;
}

- (NSMutableDictionary *)jsonObject {
    
    NSError *error = nil;
    
    NSData *jsonData = [self.customData dataUsingEncoding:NSUTF8StringEncoding];
    
    if (jsonData) {
        
        NSDictionary *representationObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
             return @{}.mutableCopy;
        }
        else {
            return representationObject.mutableCopy;
        }
    }
    else {
        return @{}.mutableCopy;
    }
}

- (void)setAvatarURL:(NSString *)avatarURL {
    
    self.context[QBAvatarURLKey] = avatarURL;
}

- (NSString *)avatarURL {
    
    return self.context[QBAvatarURLKey];
}

- (void)setStatus:(NSString *)status {
    
    self.context[QBStatusKey] = status;
}

-(NSString *)status {
    
    return self.context[QBStatusKey];
}

- (void)setImported:(BOOL)imported {
    
    self.context[QBIsImportedKey] = @(imported);
}

- (BOOL)imported {
    
    return [self.context[QBIsImportedKey] boolValue];
}

- (void)syncronize {
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.context
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    self.customData = [[NSString alloc] initWithData:jsonData
                                            encoding:NSUTF8StringEncoding];
}

- (BOOL)customDataChanged {
    return ![self.context isEqualToDictionary:self.jsonObject];
}

@end
