//
//  QMCancellable.h
//  Pods
//
//  Created by Injoit on 6/27/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QMCancellableService <NSObject>

- (void)cancelOperationWithID:(NSString *)operationID;
- (void)cancelAllOperations;

@end
