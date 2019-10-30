//
//  NSURL+QMShareExtension.h
//  QMShareExtension
//
//  Created by Injoit on 10/20/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
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
