//
//  QMSearchDataProvider.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/2/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMTableViewDataSource.h"
#import "QMSearchProtocols.h"

@class QMSearchDataProvider;

@protocol QMSearchDataProviderDelegate <NSObject>

- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)searchDataProvider;

@end

@interface QMSearchDataProvider : NSObject

@property (weak, nonatomic) QMTableViewDataSource *dataSource;

@property (weak, nonatomic) id<QMSearchDataProviderDelegate> delegate;

- (instancetype)initWithDataSource:(QMTableViewDataSource *)dataSource;

- (void)performSearch:(NSString *)searchText;

@end
