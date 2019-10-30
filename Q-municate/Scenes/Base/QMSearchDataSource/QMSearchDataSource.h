//
//  QMSearchDataSource.h
//  Q-municate
//
//  Created by Injoit on 3/2/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
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


