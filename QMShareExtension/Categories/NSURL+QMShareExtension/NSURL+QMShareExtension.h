//
//  NSURL+QMShareExtension.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/20/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <BFTask.h>

@class CLLocation;

@interface NSURL (QMShareExtension)

- (BOOL)isLocationURL;

- (CLLocationCoordinate2D)locationCoordinate;

- (BFTask <CLLocation *>*)location;


@end
