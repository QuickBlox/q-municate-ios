//
//  QBChatMessage+QMChatLocation.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

extern NSString * const QMChatLocationMessageTypeName;

@interface QBChatMessage (QMChatLocation)

- (BOOL)isLocationMessage;

- (void)addLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate;

- (CLLocationCoordinate2D)locationCoordinate;

@end
