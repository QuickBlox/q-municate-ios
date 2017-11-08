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

@property (nonatomic, strong, readonly) NSMutableSet <id<QMShareItemProtocol>>* selectedItems;
@property (nonatomic, copy) NSArray <NSSortDescriptor *> *sortDescriptors;

- (instancetype)initWithShareItems:(NSArray<id<QMShareItemProtocol>> *)shareItems
                   sortDescriptors:(nullable NSArray <NSSortDescriptor *> *)sortDescriptors
            alphabetizedDataSource:(BOOL)alphabetized;

- (void)selectItem:(id<QMShareItemProtocol>)item
           forView:(nullable id <QMShareViewProtocol>)view;

@end

@interface QMShareDataSource (QMTableViewDataSource) <UITableViewDataSource>

@end

@interface QMShareDataSource (QMCollectionViewDataSource) <UICollectionViewDataSource>

@end

@interface QMShareSearchControllerDataSource : QMShareDataSource 

@property (nonatomic, strong) QMShareDataSource<UICollectionViewDataSource> *contactsDataSource;

@property (nonatomic, assign, readonly) BOOL showContactsSection;

@end



NS_ASSUME_NONNULL_END
