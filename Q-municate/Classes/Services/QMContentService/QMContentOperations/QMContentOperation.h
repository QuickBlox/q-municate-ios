//
//  QMContentOperation.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 28.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMContentOperation : NSOperation

@property (copy, nonatomic) QMContentProgressBlock progressHandler;
@property (copy, nonatomic) id completionHandler;

@property (strong, nonatomic) QBRequest *cancelableRequest;

@end
