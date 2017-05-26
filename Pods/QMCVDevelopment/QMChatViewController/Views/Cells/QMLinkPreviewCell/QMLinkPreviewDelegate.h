//
//  QMLinkPreviewDelegate.h
//
//
//  Created by Vitaliy Gurkovsky on 5/6/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QMLinkPreviewDelegate <NSObject>

@property (nonatomic, copy, readonly, nullable) void (^imageDidSet)();
@property (nonatomic, copy, readonly, nullable) NSString *siteTitle;
@property (nonatomic, copy, readonly, nullable) NSString *siteDescription;
@property (nonatomic, copy, readonly, nullable) NSString *siteURL;

@property (nonatomic, copy, readonly, nullable) NSString *imageURL;

+ (nullable UIImage *)imageForURLKey:(NSString *)urlKey;

- (void)setSiteURL:(NSString *)siteURL
          imageURL:(nullable NSString *)imageURL
         siteTitle:(NSString *)siteTitle
   siteDescription:(nullable NSString *)siteDescription
     onImageDidSet:(nullable void(^)())imageDidSet;

@end

NS_ASSUME_NONNULL_END
