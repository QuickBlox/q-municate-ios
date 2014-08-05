//
//  QMBaseService.h
//  Q-municate
//
//  Created by Andrey on 04.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMServiceProtocol.h"

@interface QMBaseService : NSObject <QMServiceProtocol>

@property (assign, nonatomic, getter = isActive) BOOL active;

- (void)start;
- (void)stop;

@end
