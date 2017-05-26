//
//  QMImageOperation.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/23/17.
//
//

#import <UIKit/UIKit.h>
#import "QMAsynchronousOperation.h"

@class QBChatAttachment;

typedef void(^QMImageOperationCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface QMImageOperation : QMAsynchronousOperation

@property (nullable, copy, nonatomic) QMImageOperationCompletionBlock imageOperationCompletionBlock;
@property (strong, nonatomic, readonly) QBChatAttachment *attachment;

- (instancetype)initWithAttachment:(QBChatAttachment *)attachment
                 completionHandler:(nullable QMImageOperationCompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
