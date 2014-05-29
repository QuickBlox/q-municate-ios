//
//  QMContent.h
//  Q-municate
//
//  Created by Igor Alefirenko on 26/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMContent : NSObject

@property (nonatomic, assign) CGFloat uploadProgress;

- (void)loadImageForBlob:(UIImage *)image named:(NSString *)name completion:(QBContentBlock)block;
- (void)loadImageFromFacebookWithUserID:(NSString *)facebookID accessToken:(NSString *)accessToken completion:(void (^)(id object))block;

- (void)uploadImage:(UIImage *)image withCompletion:(void (^)(QBCBlob *blob, BOOL success, NSError *error))completion;

@end
