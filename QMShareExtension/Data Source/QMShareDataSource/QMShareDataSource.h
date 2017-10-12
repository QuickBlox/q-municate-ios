//
//  QMShareDataSource.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/9/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMSearchDataSource.h"
#import "QMShareItemProtocol.h"

@protocol QMShareViewProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface QMShareDataSource : QMSearchDataSource

@property (nonatomic, readonly, strong) NSMutableSet <id<QMShareItemProtocol>>* selectedItems;

- (instancetype)initWithShareItems:(NSArray <id<QMShareItemProtocol>> *)shareItems
alphabetizedDataSource:(BOOL)alphabetized;

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath
                      forView:(id <QMShareViewProtocol>)view;

@end

@interface QMShareDataSource (QMTableViewDataSource) <UITableViewDataSource>

@end

@interface QMShareDataSource (QMCollectionViewDataSource) <UICollectionViewDataSource>

@end


NS_ASSUME_NONNULL_END
