//
//  QMActivityItem.h
//  Q-municate
//
//  Created by Injoit on 10/18/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class QBChatAttachment;

NS_ASSUME_NONNULL_BEGIN

typedef void(^QMActivityItemResultBlock)(NSItemProviderCompletionHandler  _Null_unspecified completionHandler,
                                         UIActivityType activityType);

@interface QMActivityItem : NSObject <UIActivityItemSource>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPlaceholderItem:(id)placeholderItem
                         typeIdentifier:(NSString *)typeIdentifier
                       loadHandlerBlock:(nullable QMActivityItemResultBlock)loadHandlerBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithImageTypeIdentifier:(NSString *)typeIdentifier
                           loadHandlerBlock:(QMActivityItemResultBlock)loadHandlerBlock;

- (instancetype)initWithURL:(NSURL *)URL;

- (instancetype)initWithString:(NSString *)string;

- (instancetype)initWithImage:(UIImage *)image;

- (instancetype)initWithData:(NSData *)data
              typeIdentifier:(NSString *)typeIdentifier;

- (void)addItemWithTypeIdentifier:(NSString *)typeIdentifier
                 loadHandlerBlock:(QMActivityItemResultBlock)loadHandlerBlock;

@end
NS_ASSUME_NONNULL_END
