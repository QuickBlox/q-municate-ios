//
//  UIImageView+QMLocationSnapshot.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/6/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "UIImageView+QMLocationSnapshot.h"

#import <objc/runtime.h>
#import "QMCore.h"
#import "QMChatLocationSnapshotter.h"

@interface UIImageView (_QMLocationSnapshot)

@property (strong, nonatomic, setter=qm_setSnapshotKey:) NSString *qm_snapshotKey;

@end

@implementation UIImageView (_QMLocationSnapshot)

- (NSString *)qm_snapshotKey {
    
    return objc_getAssociatedObject(self, @selector(qm_snapshotKey));
}

- (void)qm_setSnapshotKey:(NSString *)qm_snapshotKey {
    
    objc_setAssociatedObject(self, @selector(qm_snapshotKey), qm_snapshotKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIImageView (QMLocationSnapshot)

- (void)setSnapshotWithKey:(NSString *)key locationCoordinate:(CLLocationCoordinate2D)locationCoordinate {
    
    self.image = nil;
    [self qm_cancelPreviousSnapshotCreation];
    
    self.qm_snapshotKey = key;
    
    @weakify(self);
    [[[QMCore instance].chatManager chatLocationSnapshotter]
     snapshotForLocationCoordinate:locationCoordinate
     withSize:self.bounds.size
     key:key
     completion:^(UIImage *snapshot) {
         
         @strongify(self);
         if ([self.qm_snapshotKey isEqualToString:key]) {
             
             self.image = snapshot;
         }
     }];
}

- (void)qm_cancelPreviousSnapshotCreation {
    
    if (self.qm_snapshotKey != nil) {
        
        [[[QMCore instance].chatManager chatLocationSnapshotter] cancelSnapshotCreationForKey:self.qm_snapshotKey];
        self.qm_snapshotKey = nil;
    }
}

@end
