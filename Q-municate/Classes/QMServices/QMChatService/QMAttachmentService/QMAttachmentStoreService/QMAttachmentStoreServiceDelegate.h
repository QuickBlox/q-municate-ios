//
//  QMMediaStoreServiceDelegate.h
//  QMMediaKit
//
//  Created by Injoit on 2/7/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBChatAttachment;
@class QMAttachmentStoreService;

NS_ASSUME_NONNULL_BEGIN

@protocol QMAttachmentStoreServiceDelegate <NSObject>

@required

- (void)storeService:(QMAttachmentStoreService *)storeService
didUpdateAttachment:(QBChatAttachment *)attachment
         messageID:(NSString *)messageID
          dialogID:(NSString *)dialogID;

- (void)storeService:(QMAttachmentStoreService *)storeService
didRemoveAttachment:(QBChatAttachment *)attachment
         messageID:(NSString *)messageID
          dialogID:(NSString *)dialogID;

@end

NS_ASSUME_NONNULL_END
