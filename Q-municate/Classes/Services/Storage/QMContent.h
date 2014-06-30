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

- (void)uploadImage:(UIImage *)image named:(NSString *)name completion:(QBFileUploadTaskResultBlock)completion;
- (void)uploadUserImageForUser:(QBUUser *)user image:(UIImage *)image withCompletion:(QBFileUploadTaskResultBlock)completion;

@end
