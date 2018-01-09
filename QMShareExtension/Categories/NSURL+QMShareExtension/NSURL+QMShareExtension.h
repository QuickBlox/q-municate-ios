//
//  NSURL+QMShareExtension.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/20/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Bolts/BFTask.h>

@class CLLocation;

@interface NSURL (QMShareExtension)

- (BOOL)isLocationURL;
- (BFTask <CLLocation *>*)location;
+ (NSURL *)appleMapsURLForLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate;

@end
