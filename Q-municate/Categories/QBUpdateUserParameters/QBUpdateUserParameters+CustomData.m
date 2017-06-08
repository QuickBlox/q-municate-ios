//
//  QBUpdateUserParameters+CustomData.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/28/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <objc/runtime.h>

NSString *const kQMAvatarUrlUpdateKey = @"avatar_url";
NSString *const kQMStatusUpdateKey = @"status";
NSString *const kQMIsImportUpdateKey = @"is_import";

@interface QBUpdateUserParameters (QMAssociatedObject)

@property (strong, nonatomic) NSMutableDictionary *context;

@end

@implementation QBUpdateUserParameters (QMAssociatedObject)

@dynamic context;

- (NSMutableDictionary *)context {
    
    NSMutableDictionary *context = objc_getAssociatedObject(self, @selector(context));
    
    if (!context) {
        
        context = [self jsonObject];
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
        if (!error) {
            return [representationObject mutableCopy];
        }
    }
    
    return [NSMutableDictionary dictionary];
}

- (void)synchronize {
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.context
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    self.customData = [[NSString alloc] initWithData:jsonData
                                            encoding:NSUTF8StringEncoding];
}

@end

@implementation QBUpdateUserParameters (CustomData)

@dynamic avatarUrl;
@dynamic status;
@dynamic isImport;

//MARK: - Is import

- (void)setIsImport:(BOOL)isImport {
    
    self.context[kQMIsImportUpdateKey] = @(isImport);
    [self synchronize];
}

- (BOOL)isImport {
    
    NSNumber *isImprot = self.context[kQMIsImportUpdateKey];
    return isImprot.boolValue;
}

//MARK: - Status

- (void)setStatus:(NSString *)status {
    
    self.context[kQMStatusUpdateKey] = [status copy];
    [self synchronize];
}

- (NSString *)status {
    
    return self.context[kQMStatusUpdateKey];
}

//MARK: - Avatar url

- (void)setAvatarUrl:(NSString *)avatarUrl {
    
    self.context[kQMAvatarUrlUpdateKey] = [avatarUrl copy];
    [self synchronize];
}

- (NSString *)avatarUrl {
    
    return self.context[kQMAvatarUrlUpdateKey];
}

@end
