//
//  QMGlobalSearchDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchDataSource.h"
#import "QMSearchProtocols.h"
#import "QMGlobalSearchDataProvider.h"
#import "QMSearchCell.h"

@interface QMGlobalSearchDataSource : QMSearchDataSource <QMGlobalSearchDataSourceProtocol, QMGlobalSearchDataProviderProtocol, QMSearchCellDelegate>

@end
