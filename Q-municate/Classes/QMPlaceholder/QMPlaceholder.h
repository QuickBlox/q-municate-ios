//
//  QMPlaceholder.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/14/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMPlaceholder : NSObject

+ (UIImage *)placeholderWithFrame:(CGRect)frame
                            title:(NSString *)title
                               ID:(NSUInteger)ID;

@end
