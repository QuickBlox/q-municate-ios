//
//  QMChatLocationSnapshotter.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 7/6/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatLocationSnapshotter.h"

#import <MapKit/MapKit.h>
#import "QMImageLoader.h"

static const CLLocationDegrees kQMMKCoordinateSpanDefaultValue = 250;

static NSString * const kQMChatLocationSnapshotCacheName = @"com.q-municate.chat.location.snapshot";

@implementation QMChatLocationSnapshotter

+ (void)snapshotForLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate withSize:(CGSize)size key:(NSString *)key completion:(QMChatLocationSnapshotBlock)completion {
    NSParameterAssert(key);
    
    UIImage *locationSnapshot = [QMImageLoader.instance.imageCache imageFromCacheForKey:key];
    
    if (locationSnapshot) {
        completion(locationSnapshot);
        return;
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationCoordinate, kQMMKCoordinateSpanDefaultValue, kQMMKCoordinateSpanDefaultValue);
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = region;
    options.size = size;
    options.scale = [UIScreen mainScreen].scale;
    
    MKMapSnapshotter *snapShotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [[[self class] _snapshotOperations] setObject:snapShotter forKey:key];
    
    [snapShotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
              completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
                  
                  if (snapshot == nil) {
                      
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
                  
                  [QMImageLoader.instance.imageCache storeImage:finalImage
                                                         forKey:key
                                                         toDisk:YES
                                                     completion:nil];
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      
                      completion(finalImage);
                  });
              }];
}

+ (void)cancelSnapshotCreationForKey:(NSString *)key {
    
    MKMapSnapshotter *snapShotter = [[[self class] _snapshotOperations] objectForKey:key];
    [snapShotter cancel];
}

#pragma mark - Private

+ (NSMapTable *)_snapshotOperations {
    
    static NSMapTable *snapshotOperations = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        snapshotOperations = [NSMapTable strongToWeakObjectsMapTable];
    });
    
    return snapshotOperations;
}

@end
