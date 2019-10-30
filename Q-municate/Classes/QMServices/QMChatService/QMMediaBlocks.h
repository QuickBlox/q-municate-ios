//
//  QMMediaBlocks.h
//  QMMediaKit
//
//  Created by Injoit on 2/8/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMChatTypes.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^QMAttachmentProgressBlock)(float progress);

typedef void (^QMAttachmentAssetLoaderCompletionBlock)(UIImage * _Nullable image, Float64 durationInSeconds, CGSize size, NSError * _Nullable error, BOOL cancelled);

NS_ASSUME_NONNULL_END

