//
//  QMTasks.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTasks.h"

@implementation QMTasks

+ (BFTask *)taskUpdateCurrentUser:(QBUpdateUserParameters *)updateParameters {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
        //
        [source setResult:user];
    } errorBlock:^(QBResponse * _Nonnull response) {
        //
        [source setError:response.error.error];
    }];
    
    return source.task;
}

@end
