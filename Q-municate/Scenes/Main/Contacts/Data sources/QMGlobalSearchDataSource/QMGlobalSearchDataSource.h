//
//  QMGlobalSearchDataSource.h
//  Q-municate
//
//  Created by Injoit on 3/1/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMTableViewDataSource.h"
#import "QMSearchProtocols.h"
#import "QMGlobalSearchDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMGlobalSearchDataSource class interface.
 *  Used as data source for global search.
 */
@interface QMGlobalSearchDataSource : QMTableViewSearchDataSource <QMGlobalSearchDataSourceProtocol, QMContactsSearchDataSourceProtocol, QMGlobalSearchDataProviderProtocol>

/**
 *  Add user block action.
 */
@property (copy, nonatomic) void (^didAddUserBlock)(UITableViewCell *cell);

@end

NS_ASSUME_NONNULL_END
