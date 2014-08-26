//
//  QMMessageBarStyleSheetFactory.h
//  Q-municate
//
//  Created by Andrey Ivanov on 07.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWMessageBarManager.h"

@interface QMMessageBarStyleSheetFactory : NSObject

+ (NSObject <TWMessageBarStyleSheet> *)defaultMsgBarWithImage:(UIImage *)img;

@end
