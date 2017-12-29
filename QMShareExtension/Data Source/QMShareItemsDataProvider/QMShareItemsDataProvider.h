//
//  QMShareItemsDataProvider.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/10/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "QMSearchDataProvider.h"

@interface QMShareItemsDataProvider : QMSearchDataProvider

- (instancetype)initWithShareItems:(NSArray *)shareItems;

@end
