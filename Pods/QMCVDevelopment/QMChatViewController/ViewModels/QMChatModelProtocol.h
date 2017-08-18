//
//  QMChatModelProtocol.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 5/18/17.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QMModelContentType) {
    
    QMModelContentTypeChatMessage = 0,
    QMModelContentTypeAudio = 1,
    QMModelContentTypeVideo,
    QMModelContentTypeImage,
    QMModelContentTypeLink,
    QMModelContentTypeCustom
};

NS_ASSUME_NONNULL_BEGIN

@protocol QMChatModelProtocol <NSObject>

@property (nonatomic, copy, nullable) NSString *modelID;
@property (nonatomic, assign) QMModelContentType modelContentType;

@end
NS_ASSUME_NONNULL_END
