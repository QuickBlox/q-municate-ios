//
//  QMActivityItem.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 10/18/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QMActivityItem : NSObject <UIActivityItemSource>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPlaceholderItem:(id)placeholderItem
                         typeIdentifier:(NSString *)typeIdentifier NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithURL:(NSURL *)URL;

- (instancetype)initWithString:(NSString *)string;

- (instancetype)initWithImage:(UIImage *)image;

- (instancetype)initWithData:(NSData *)data
              typeIdentifier:(NSString *)typeIdentifier;


@end
