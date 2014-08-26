//
//  QMContentOperation.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 28.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^QMTaskResultBlock)(id taskResult);

@interface QMContentOperation : NSOperation <QBActionStatusDelegate>

@property (copy, nonatomic) QMContentProgressBlock progressHandler;
@property (copy, nonatomic) id completionHandler;

@property (strong, nonatomic) NSObject<Cancelable>*cancelableOperation;

@end
