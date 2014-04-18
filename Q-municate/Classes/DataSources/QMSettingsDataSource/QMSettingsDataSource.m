//
//  QMSettingsDataSource.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/14/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSettingsDataSource.h"

@implementation QMSettingsDataSource

- (NSInteger)countForDataSourceWithMode:(SettingsViewControllerMode)settingsMode
{
    if (settingsMode == SettingsViewControllerModeNormal) {
        return 5;
    }
    return 4;
}


@end
