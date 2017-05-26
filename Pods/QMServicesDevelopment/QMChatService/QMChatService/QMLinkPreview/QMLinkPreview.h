//
//  QMLinkPreview.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 4/3/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMLinkPreview : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy, nullable) NSString *siteUrl;
@property (nonatomic, copy, nullable) NSString *siteTitle;
@property (nonatomic, copy, nullable) NSString *siteDescription;
@property (nonatomic, copy, nullable) NSString *imageURL;
@property (nonatomic, assign) NSUInteger imageHeight;
@property (nonatomic, assign) NSUInteger imageWidth;

@end
NS_ASSUME_NONNULL_END
