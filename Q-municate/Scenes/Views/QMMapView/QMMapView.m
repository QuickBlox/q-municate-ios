//
//  QMMapView.m
//  Q-municate
//
//  Created by Injoit on 7/4/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMMapView.h"

@interface QMMapView ()
{
    CLGeocoder *_geoCoder;
    MKPointAnnotation *_pin;
}

@end

@implementation QMMapView

- (void)setManipulationsEnabled:(BOOL)enabled {
    
    self.zoomEnabled = enabled;
    self.scrollEnabled = enabled;
    
    if ([self respondsToSelector:@selector(setRotateEnabled:)]) {
        
        self.rotateEnabled = enabled;
    }
    
    if ([self respondsToSelector:@selector(setPitchEnabled:)]) {
        
        self.pitchEnabled = enabled;
    }
}

- (void)markCoordinate:(CLLocationCoordinate2D)coordinate {
    
    [self markCoordinate:coordinate animated:NO];
}

- (void)markCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, MKCoordinateSpanDefaultValue, MKCoordinateSpanDefaultValue);
    [self setRegion:region animated:animated];
    
    // remove previous marker
    [self removeAnnotation:_pin];
    
    // create a new marker in the middle
    _pin = [[MKPointAnnotation alloc] init];
    _pin.coordinate = coordinate;
    [self addAnnotation:_pin];
    [self selectAnnotation:_pin animated:NO];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                      longitude:coordinate.longitude];
    
    __weak typeof(self) weakSelf = self;
    //Adding address as title of the annotation
    [[self geocoder] reverseGeocodeLocation:location
                          completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                              
                              CLPlacemark *placemark = placemarks.firstObject;
                              if (placemark) {
                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                  NSString *locatedAt = [placemark.addressDictionary[@"FormattedAddressLines"] componentsJoinedByString:@", "];
                                  if (strongSelf && locatedAt) {
                                      strongSelf->_pin.title = locatedAt;
                                  }
                              }
                              else if (error) {
                                  NSLog(@"Could not locate");
                              }
                          }];
}

- (CLGeocoder *)geocoder {
    
    if (!_geoCoder) {
        _geoCoder = [[CLGeocoder alloc] init];
    }
    
    return _geoCoder;
}

@end
