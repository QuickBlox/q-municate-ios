//
//  QMMediaInfo.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/26/17.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QMMediaPrepareStatus) {
    
    QMMediaPrepareStatusNotPrepared,
    QMMediaPrepareStatusPreparing,
    QMMediaPrepareStatusPrepareFinished,
    QMMediaPrepareStatusPrepareFailed
};

@class QBChatAttachment;

@interface QMMediaInfo : NSObject

@property (assign, nonatomic, readonly) CGSize mediaSize;
@property (assign, nonatomic, readonly) NSTimeInterval duration;

@property (strong, nonatomic, readonly) UIImage *thumbnailImage;
@property (strong, nonatomic, readonly) AVPlayerItem *playerItem;
@property (assign, nonatomic, readonly) QMMediaPrepareStatus prepareStatus;

+ (instancetype)infoFromAttachment:(QBChatAttachment *)attachment;
- (void)cancel;

- (void)prepareWithCompletion:(void(^)(NSTimeInterval duration, CGSize size, UIImage *image, NSError *error))completion;

@end
