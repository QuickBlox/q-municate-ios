//
//  QMLinkPreviewMemoryStorage.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 4/3/17.
//
//

#import <Foundation/Foundation.h>
#import "QMMemoryStorageProtocol.h"

@class QMLinkPreview;

NS_ASSUME_NONNULL_BEGIN

@interface QMLinkPreviewMemoryStorage : NSObject <QMMemoryStorageProtocol>

- (nullable QMLinkPreview *)linkPreviewForKey:(NSString *)urlKey;
- (void)addLinkPreview:(QMLinkPreview *)preview forKey:(NSString *)urlKey;
- (void)updateLinkPreview:(QMLinkPreview *)preview forKey:(NSString *)urlKey;
- (void)removeLinkPreview:(QMLinkPreview *)preview forKey:(NSString *)urlKey;

@end

NS_ASSUME_NONNULL_END
