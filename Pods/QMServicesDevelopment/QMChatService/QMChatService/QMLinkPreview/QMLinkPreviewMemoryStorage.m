//
//  QMLinkPreviewMemoryStorage.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 4/3/17.
//
//

#import "QMLinkPreviewMemoryStorage.h"

@interface QMLinkPreviewMemoryStorage()

@property (strong, nonatomic, nullable) NSMutableDictionary *memoryStorage;

@end

@implementation QMLinkPreviewMemoryStorage

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _memoryStorage = [NSMutableDictionary dictionary];
    }
    return self;
}

- (QMLinkPreview *)linkPreviewForKey:(NSString *)urlKey {
    
    NSAssert(urlKey != nil, @"urlKey shouldn't be nil");
    return _memoryStorage[urlKey];
}

- (void)addLinkPreview:(QMLinkPreview *)preview forKey:(NSString *)urlKey {
    
    NSAssert(urlKey != nil, @"urlKey shouldn't be nil");
    _memoryStorage[urlKey] = preview;
}

- (void)updateLinkPreview:(QMLinkPreview *)preview forKey:(NSString *)urlKey {
    
    [self addLinkPreview:preview forKey:urlKey];
}

- (void)removeLinkPreview:(QMLinkPreview *)preview forKey:(NSString *)urlKey {
    
    NSAssert(urlKey != nil, @"urlKey shouldn't be nil");
    [_memoryStorage removeObjectForKey:urlKey];
}

- (void)free {
    [_memoryStorage removeAllObjects];
}


@end
