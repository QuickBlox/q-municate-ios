//
//  QMChatLocationSnapshotter.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/6/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatLocationSnapshotter.h"

#import <MapKit/MapKit.h>

static const NSUInteger kQMChatLocationSnapshotCacheCountLimit = 200;
static NSString * const kQMChatLocationSnapshotCacheName = @"com.q-municate.chat.location.snapshot";

@interface QMChatLocationSnapshotter ()
{
    NSCache *_cache;
    
    NSMapTable *_snapshotOperations;
}

@end

@implementation QMChatLocationSnapshotter

- (instancetype)init {
    
    self = [super init];
    if (self != nil) {
        
        _cache = [[NSCache alloc] init];
        _cache.countLimit = kQMChatLocationSnapshotCacheCountLimit;
        _cache.name = kQMChatLocationSnapshotCacheName;
        
        _snapshotOperations = [NSMapTable strongToWeakObjectsMapTable];
    }
    
    return self;
}

- (void)snapshotForLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate withSize:(CGSize)size key:(NSString *)key completion:(QMChatLocationSnapshotBlock)completion {
    
    UIImage *locationSnapshot = [_cache objectForKey:key];
    if (locationSnapshot != nil) {
        
        completion(locationSnapshot);
        return;
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationCoordinate, MKCoordinateSpanDefaultValue, MKCoordinateSpanDefaultValue);
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = region;
    options.size = size;
    options.scale = [UIScreen mainScreen].scale;
    
    MKMapSnapshotter *snapShotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [_snapshotOperations setObject:snapShotter forKey:key];
    
    @weakify(self);
    [snapShotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
              completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
                  
                  @strongify(self);
                  
                  if (snapshot == nil) {
                      
                      ILog(@"%s Error creating map snapshot: %@", __PRETTY_FUNCTION__, error);
                      completion(nil);
                      return;
                  }
                  
                  MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
                  CGPoint coordinatePoint = [snapshot pointForCoordinate:locationCoordinate];
                  UIImage *image = snapshot.image;
                  
                  coordinatePoint.x += pin.centerOffset.x - (CGRectGetWidth(pin.bounds) / 2.0);
                  coordinatePoint.y += pin.centerOffset.y - (CGRectGetHeight(pin.bounds) / 2.0);
                  
                  UIImage *finalImage = nil;
                  
                  UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
                  {
                      [image drawAtPoint:CGPointZero];
                      [pin.image drawAtPoint:coordinatePoint];
                      finalImage = UIGraphicsGetImageFromCurrentImageContext();
                  }
                  UIGraphicsEndImageContext();
                  
                  [self->_cache setObject:finalImage forKey:key];
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      
                      completion(finalImage);
                  });
              }];
}

- (void)cancelSnapshotCreationForKey:(NSString *)key {
    
    MKMapSnapshotter *snapShotter = [_snapshotOperations objectForKey:key];
    [snapShotter cancel];
}

@end
