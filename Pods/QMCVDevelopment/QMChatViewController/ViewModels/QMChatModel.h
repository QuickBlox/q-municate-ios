//
//  QMChatModel.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 5/19/17.
//
//

#import <Foundation/Foundation.h>
#import "QMModelProtocol.h"

@interface QMChatModel : NSObject <QMModelProtocol>

+ (instancetype)modelWithID:(NSString *)modelID
                    message:(QBChatMessage *)message;

@end
