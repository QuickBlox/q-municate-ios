//
//  QMChatLocationSnapshotter.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/6/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QMChatLocationSnapshotBlock)(UIImage * _Nullable snapshot);

@interface QMChatLocationSnapshotter : NSObject

- (void)snapshotForLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate
                             withSize:(CGSize)size
                                  key:(NSString *)key
                           completion:(QMChatLocationSnapshotBlock)completion;

- (void)cancelSnapshotCreationForKey:(NSString *)key;

NS_ASSUME_NONNULL_END

@end
