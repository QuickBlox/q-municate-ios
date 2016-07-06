//
//  QMBaseChatLocationCell.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMBaseChatLocationCell.h"

#import "QMMapView.h"

@interface QMBaseChatLocationCell ()
{
    CLLocationCoordinate2D _locationCoordinate;
}

@property (weak, nonatomic) IBOutlet QMMapView *mapView;

@end


@implementation QMBaseChatLocationCell

#pragma mark - Life cycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.mapView setManipulationsEnabled:NO];
}

#pragma mark - QMChatLocationCell protocol implementation

- (void)setLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate {
    
    _locationCoordinate = locationCoordinate;
    [self.mapView markCoordinate:locationCoordinate animated:NO];
}

- (CLLocationCoordinate2D)locationCoordinate {
    
    return _locationCoordinate;
}

@end
