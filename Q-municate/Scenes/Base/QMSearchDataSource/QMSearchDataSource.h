//
//  QMSearchDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/2/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTableViewDataSource.h"


@protocol QMSearchDataSourceProtocol <NSObject>

@property (strong, nonatomic) QMSearchDataProvider *searchDataProvider;

- (instancetype)initWithSearchDataProvider:(QMSearchDataProvider *)searchDataProvider;

@end


@interface QMSearchDataSource : QMDataSource <QMSearchDataSourceProtocol>

@end


@interface QMTableViewSearchDataSource : QMTableViewDataSource <QMSearchDataSourceProtocol>

@end
