//
//  QMServices.m
//  QMServices
//
//  Created by Injoit on 21.11.14.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMServicesManager.h"

@interface QMServices_lib : NSObject
@end

@implementation QMServices_lib

- (void)main {
    [QMServicesManager instance];
}
@end
