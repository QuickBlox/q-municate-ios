//
//  QMCore.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMCore.h"
#import <Reachability.h>
#import "QMProfile.h"
#import "QMFacebook.h"
#import <DigitsKit/DigitsKit.h>

NSString *const kQMLastActivityDateKey = @"last_activity_date";

@interface QMCore ()

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation QMCore

+ (instancetype)instance {
    
    static QMCore *core = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        core = [[self alloc] init];
    });
    
    return core;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Contact list service init
        [QMContactListCache setupDBWithStoreNamed:kContactListCacheNameKey];
        _contactListService = [[QMContactListService alloc] initWithServiceManager:self cacheDataSource:self];
        
        // Profile init
        _currentProfile = [QMProfile currentProfile];
        
        // Users cache init
        [self.usersService loadFromCache];
        
        // Reachability init
//        _internetConnection = [Reachability reachabilityForInternetConnection];
        
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

#pragma mark - Auth methods

- (BFTask *)logout {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    @weakify(self);
    [super logoutWithCompletion:^{
        @strongify(self);
        
        if (self.currentProfile.accountType == QMAccountTypeFacebook) {
            
            [QMFacebook logout];
        } else if (self.currentProfile.accountType == QMAccountTypeDigits) {
            
            [[Digits sharedInstance] logOut];
        }
        
        [self.currentProfile clearProfile];
        
        [source setResult:nil];
    }];
    
    return source.task;
}

#pragma mark - Last activity date

- (void)setLastActivityDate:(NSDate *)lastActivityDate
{
    [self.defaults setObject:lastActivityDate forKey:kQMLastActivityDateKey];
    [self.defaults synchronize];
}

- (NSDate *)lastActivityDate
{
    return [self.defaults objectForKey:kQMLastActivityDateKey];
}

#pragma mark QMContactListServiceCacheDelegate delegate

- (void)cachedContactListItems:(QMCacheCollection)block {
    [[QMContactListCache instance] contactListItems:block];
}

@end
