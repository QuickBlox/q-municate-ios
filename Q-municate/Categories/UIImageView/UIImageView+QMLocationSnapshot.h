//
//  UIImageView+QMLocationSnapshot.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/6/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (QMLocationSnapshot)

- (void)setSnapshotWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate;

@end
