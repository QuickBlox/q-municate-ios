//
//  QMMapView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/4/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMMapView.h"

@interface QMMapView ()
{
    MKPlacemark *_pin;
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
    _pin = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    [self addAnnotation:_pin];
    [self selectAnnotation:_pin animated:NO];
}

@end
