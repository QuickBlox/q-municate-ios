//
//  QMServiceProtocol.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 17.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

@protocol QMServiceProtocol <NSObject>

@property (assign, nonatomic, getter = isActive) BOOL active;

- (void)start;
- (void)stop;

@end
