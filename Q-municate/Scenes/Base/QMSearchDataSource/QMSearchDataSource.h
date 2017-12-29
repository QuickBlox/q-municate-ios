//
//  QMSearchDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/2/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDataSource.h"

@class QMSearchDataProvider;

@protocol QMSearchDataSourceProtocol <NSObject>

@property (strong, nonatomic) QMSearchDataProvider *searchDataProvider;

- (void)performSearch:(NSString *)searchText;
- (instancetype)initWithSearchDataProvider:(QMSearchDataProvider *)searchDataProvider;

@end


@interface QMSearchDataSource : QMDataSource <QMSearchDataSourceProtocol>

@end


