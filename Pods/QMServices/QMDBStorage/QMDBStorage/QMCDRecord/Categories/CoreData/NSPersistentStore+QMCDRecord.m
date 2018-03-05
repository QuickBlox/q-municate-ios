//
//  NSPersistentStore+QMCDRecord.m
//
//  Created by Injoit on 3/11/10.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSPersistentStore+QMCDRecord.h"
#import "QMCDRecord.h"
#import "NSError+QMCDRecordErrorHandling.h"
#import "QMCDRecordLogging.h"
#import "NSPersistentStore+QMCDRecordPrivate.h"

@implementation NSPersistentStore (QMCDRecord)

+ (NSURL *)QM_defaultLocalStoreUrl;
{
    return [self QM_fileURLForStoreName:[QMCDRecord defaultStoreName]];
}

+ (NSURL *)QM_fileURLForStoreName:(NSString *)storeFileName {
    return [self QM_fileURLForStoreName:storeFileName applicationGroupIdentifier:nil];
}

+ (NSURL *)QM_fileURLForStoreName:(NSString *)storeFileName applicationGroupIdentifier:(NSString *)appGroupIdentifier
{
    NSURL *storeURL = [self QM_fileURLForStoreNameIfExistsOnDisk:storeFileName applicationGroupIdentifier:appGroupIdentifier];
    
    if (storeURL == nil)
    {
        NSString *storePath = [QM_defaultApplicationStorePath() stringByAppendingPathComponent:storeFileName];
        
        if (appGroupIdentifier.length
            && QM_storePathForApplicationGroupIdentifier(appGroupIdentifier).length > 0) {
            
            storePath = [QM_storePathForApplicationGroupIdentifier(appGroupIdentifier) stringByAppendingPathComponent:storeFileName];
        }
        
        storeURL = [NSURL fileURLWithPath:storePath];
    }
    
    return storeURL;
}

+ (NSURL *)QM_fileURLForStoreNameIfExistsOnDisk:(NSString *)storeFileName applicationGroupIdentifier:(NSString *)appGroupIdentifier
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    NSMutableArray *paths = [NSMutableArray array];
    
    if (appGroupIdentifier.length
        && QM_storePathForApplicationGroupIdentifier(appGroupIdentifier).length > 0) {
        [paths addObject:QM_storePathForApplicationGroupIdentifier(appGroupIdentifier)];
    }
    else {
        [paths addObjectsFromArray:@[QM_defaultApplicationStorePath(),QM_userDocumentsPath()]];
    }
    
    for (NSString *path in paths.copy)
    {
        NSString *filepath = [path stringByAppendingPathComponent:storeFileName];
        
        if ([fm fileExistsAtPath:filepath])
        {
            return [NSURL fileURLWithPath:filepath];
        }
    }
    
    return nil;
}

+ (NSURL *)QM_cloudURLForUbiqutiousContainer:(NSString *)bucketName;
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *cloudURL = nil;
    if ([fileManager respondsToSelector:@selector(URLForUbiquityContainerIdentifier:)])
    {
        cloudURL = [fileManager URLForUbiquityContainerIdentifier:bucketName];
    }

    return cloudURL;
}

- (BOOL)QM_isSqliteStore;
{
    return [[self type] isEqualToString:NSSQLiteStoreType];
}

- (BOOL)QM_copyToURL:(NSURL *)destinationUrl error:(NSError **)error;
{
    if (![self QM_isSqliteStore])
    {
        QMCDLogWarn(@"NSPersistentStore [%@] is not a %@", self, NSSQLiteStoreType);
        return NO;
    }

    NSArray *storeUrls = [self QM_sqliteURLs];

    BOOL success = YES;
    NSFileManager *fileManager = [[NSFileManager alloc] init];

    for (NSURL *storeUrl in storeUrls)
    {
        NSURL *copyToURL = [destinationUrl URLByDeletingPathExtension];
        copyToURL = [copyToURL URLByAppendingPathExtension:[storeUrl pathExtension]];
        success &= [fileManager copyItemAtURL:storeUrl toURL:copyToURL error:error];
    }
    return success;
}

- (NSArray *)QM_sqliteURLs;
{
    if (![self QM_isSqliteStore])
    {
        QMCDLogWarn(@"NSPersistentStore [%@] is not a %@", self, NSSQLiteStoreType);
        return nil;
    }

    NSURL *primaryStoreURL = [self URL];
    NSAssert([primaryStoreURL isFileURL], @"Store URL [%@] does not point to a resource on the local file system", primaryStoreURL);
    
    NSMutableArray *storeURLs = [NSMutableArray arrayWithObject:primaryStoreURL];
    NSArray *extensions = @[@"sqlite-wal", @"sqlite-shm"];

    for (NSString *extension in extensions)
    {
        NSURL *extensionURL = [primaryStoreURL URLByDeletingPathExtension];
        extensionURL = [extensionURL URLByAppendingPathExtension:extension];

        NSError *error;
        BOOL fileExists = [extensionURL checkResourceIsReachableAndReturnError:&error];
        if (fileExists)
        {
            [storeURLs addObject:extensionURL];
        }
        [[error QM_coreDataDescription] QM_logToConsole];
    }
    return [NSArray arrayWithArray:storeURLs];
}

//MARK: - Remove Store File(s)

- (BOOL)QM_removePersistentStoreFiles;
{
    return [[self class] QM_removePersistentStoreFilesAtURL:self.URL];
}

+ (NSDictionary *)QM_migrationOptionsForStoreName:(NSString *)storeFileName
                       applicationGroupIdentifier:(NSString *)appGroupIdentifier
{

    NSURL *sourceURL = [self QM_fileURLForStoreName:storeFileName];
    
    if (appGroupIdentifier.length == 0) {
        
        return @{QMCDRecordTargetURLKey : sourceURL};
    }
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    BOOL needMigrate = NO;
    BOOL needDeleteOld  = NO;
    
    NSURL *groupURL = [self QM_fileURLForStoreName:storeFileName applicationGroupIdentifier:appGroupIdentifier];
    
    NSURL *targetURL =  nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[sourceURL path]]) {
        targetURL = sourceURL;
        needMigrate = YES;
    }
    
    if ([fileManager fileExistsAtPath:[groupURL path]]) {
        needMigrate = NO;
        targetURL = groupURL;
        
       if ([fileManager fileExistsAtPath:[sourceURL path]]) {
            needDeleteOld = YES;
        }
    }
    
    if (targetURL == nil) {
        targetURL = groupURL;
    }

    options[QMCDRecordShouldMigrateKey] = @(needMigrate);
    options[QMCDRecordShouldDeleteOldDBKey] = @(needDeleteOld);
    
    if (sourceURL != nil) {
    options[QMCDRecordSourceURLKey] = sourceURL;
    }
    if (targetURL != nil) {
    options[QMCDRecordTargetURLKey] = targetURL;
    }
    if (groupURL != nil) {
        options[QMCDRecordGroupURLKey] = groupURL;
    }
    return options.copy;
}

+ (BOOL)QM_removePersistentStoreFilesAtURL:(NSURL*)url;
{
    NSCAssert([url isFileURL], @"URL must be a file URL");

    NSString *rawURL = [url absoluteString];
    NSURL *shmSidecar = [NSURL URLWithString:[rawURL stringByAppendingString:@"-shm"]];
    NSURL *walSidecar = [NSURL URLWithString:[rawURL stringByAppendingString:@"-wal"]];

    BOOL removeItemResult = YES;
    NSError *removeItemError;

    for (NSURL *toRemove in @[url, shmSidecar, walSidecar])
    {
        BOOL itemResult = [[NSFileManager defaultManager] removeItemAtURL:toRemove error:&removeItemError];

        if (NO == itemResult)
        {
            [[removeItemError localizedDescription] QM_logToConsole];
            [[removeItemError localizedFailureReason] QM_logToConsole];
            [[removeItemError localizedRecoverySuggestion] QM_logToConsole];
        }

        // If the file doesn't exist, that's OK — that's still a successful result!
        removeItemResult = removeItemResult && (itemResult || [removeItemError code] == NSFileNoSuchFileError);
    }

    return removeItemResult;
}

@end


NSString *QM_storePathForApplicationGroupIdentifier(NSString *groupidentifier)
{
    NSURL *directory = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupidentifier];
    return directory.path;
}

NSString *QM_defaultApplicationStorePath(void)
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(id)kCFBundleNameKey];
    NSString *applicationStorePath = [documentPath stringByAppendingPathComponent:applicationName];

    return applicationStorePath;
}

NSString *QM_userDocumentsPath(void)
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    return documentPath;
}

