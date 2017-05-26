//
//  QMViewModel.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 5/18/17.
//
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>


typedef NS_ENUM(NSInteger, QMModelContentType) {
    
    QMModelContentTypeChatMessage = 0,
    QMModelContentTypeAudio = 1,
    QMModelContentTypeVideo,
    QMModelContentTypeImage,
    QMModelContentTypeLink,
    QMModelContentTypeCustom
};

NS_ASSUME_NONNULL_BEGIN
@protocol QMModelProtocol <NSObject>

@property (nonatomic, strong, nullable) QBChatMessage *message;

@property (nonatomic, copy, nullable) NSString *modelID;
@property (nonatomic, copy, nullable) NSString *fileURLPath;

@property (nonatomic, assign) QMModelContentType modelContentType;


//Object subscription. E.g. object[@"key"] = value.
- (nullable id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key;

@end
NS_ASSUME_NONNULL_END
