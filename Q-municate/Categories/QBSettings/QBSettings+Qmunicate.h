//
//  QBSettings+Qmunicate.h
//  Q-municate
//
//  Created by Injoit on 11/3/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

typedef NS_ENUM(NSUInteger, QMApplicationZone) {
    QMApplicationZoneDevelopment,
    QMApplicationZoneProduction,
    QMApplicationZoneQA
};

static const QMApplicationZone QMCurrentApplicationZone = QMApplicationZoneProduction;

@interface QBSettings (Qmunicate)

+ (void)configure;

@end
