//
//  QMSearchDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/2/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTableViewDatasource.h"

@interface QMSearchDataSource : QMTableViewDataSource

@property (strong, nonatomic) QMSearchDataProvider *searchDataProvider;

- (instancetype)initWithSearchDataProvider:(QMSearchDataProvider *)searchDataProvider;

@end
