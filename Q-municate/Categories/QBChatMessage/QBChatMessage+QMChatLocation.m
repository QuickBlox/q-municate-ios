//
//  QBChatMessage+QMChatLocation.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QBChatMessage+QMChatLocation.h"

NSString * const QMChatLocationMessageTypeName = @"location";

static NSString * const kQMLocationLatitudeKey = @"lat";
static NSString * const kQMLocationLongitudeKey = @"lng";

@implementation QBChatMessage (QMChatLocation)

- (BOOL)isLocationMessage {
    
    __block BOOL isLocationMessage = NO;
    
    [self.attachments enumerateObjectsUsingBlock:^(QBChatAttachment * _Nonnull obj, NSUInteger __unused idx, BOOL * _Nonnull stop) {
        
        if ([obj.type isEqualToString:QMChatLocationMessageTypeName]) {
            
            isLocationMessage = YES;
            *stop = YES;
        }
    }];
    
    return isLocationMessage;
}

- (void)addLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate {
    
    QBChatAttachment *locationAttachment = [[QBChatAttachment alloc] init];
    
    locationAttachment.type = QMChatLocationMessageTypeName;
    [locationAttachment.context setObject:[NSString stringWithFormat:@"%lf", locationCoordinate.latitude] forKey:kQMLocationLatitudeKey];
    [locationAttachment.context setObject:[NSString stringWithFormat:@"%lf", locationCoordinate.longitude] forKey:kQMLocationLongitudeKey];
    [locationAttachment synchronize];
    
    self.attachments = @[locationAttachment];
}

- (CLLocationCoordinate2D)locationCoordinate {
    
    QBChatAttachment *locationAttachment = [self _locationAttachment];
    
    if (locationAttachment == nil) {
        
        return kCLLocationCoordinate2DInvalid;
    }
    
    CLLocationDegrees lat = [[locationAttachment.context objectForKey:kQMLocationLatitudeKey] doubleValue];
    CLLocationDegrees lng = [[locationAttachment.context objectForKey:kQMLocationLongitudeKey] doubleValue];
    
    NSLog(@"lat: %@, lng: %@", [locationAttachment.context objectForKey:kQMLocationLatitudeKey],
          [locationAttachment.context objectForKey:kQMLocationLongitudeKey]);
    
    return CLLocationCoordinate2DMake(lat, lng);
}

#pragma mark - Private

- (QBChatAttachment *)_locationAttachment {
    
    __block QBChatAttachment *locationAttachment = nil;
    
    [self.attachments enumerateObjectsUsingBlock:^(QBChatAttachment * _Nonnull obj, NSUInteger __unused idx, BOOL * _Nonnull stop) {
        
        if ([obj.type isEqualToString:QMChatLocationMessageTypeName]) {
            
            locationAttachment = obj;
            *stop = YES;
        }
    }];
    
    return locationAttachment;
}

@end
