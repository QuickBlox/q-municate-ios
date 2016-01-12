//
//  QMDigitsConfigurationFactory.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/12/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DGTAuthenticationConfiguration;

@interface QMDigitsConfigurationFactory : NSObject

+ (DGTAuthenticationConfiguration *)qmunicateThemeConfiguration;

@end
