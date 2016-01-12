//
//  QMDigitsConfigurationFactory.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/12/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDigitsConfigurationFactory.h"
#import <DGTAuthenticationConfiguration.h>
#import <DGTAppearance.h>

@implementation QMDigitsConfigurationFactory

+ (DGTAuthenticationConfiguration *)qmunicateThemeConfiguration {
    
    DGTAuthenticationConfiguration *configuration = [[DGTAuthenticationConfiguration alloc] initWithAccountFields:DGTAccountFieldsDefaultOptionMask];
    
    DGTAppearance *appearance = [[DGTAppearance alloc] init];
    appearance.logoImage = [UIImage imageNamed:@"logo_splash"];
    appearance.headerFont = [UIFont systemFontOfSize:17];
    appearance.accentColor = [UIColor colorWithRed:0.0f/255.0f green:191.0f/255.0f blue:40.0f/255.0f alpha:1.0f];
    
    configuration.appearance = appearance;
    configuration.title = NSLocalizedString(@"QM_STR_PHONE_VERIFICATION", nil);
    
    return configuration;
}

@end
