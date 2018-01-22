//
//  QBSettings+Qmunicate.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/3/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

typedef NS_ENUM(NSUInteger, QMApplicationZone) {
    QMApplicationZoneDevelopment,
    QMApplicationZoneDevelopment1,
    QMApplicationZoneProduction,
    QMApplicationZoneQA,
};

static const QMApplicationZone QMCurrentApplicationZone = QMApplicationZoneQA;

@interface QBSettings (Qmunicate)

+ (void)configure;

@end
