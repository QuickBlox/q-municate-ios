//
//  QMSearchDataProvider.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/2/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMSearchDataSource.h"
#import "QMSearchProtocols.h"

@class QMSearchDataProvider;

@protocol QMSearchDataProviderDelegate <NSObject>

- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)searchDataProvider;
- (void)searchDataProvider:(QMSearchDataProvider *)searchDataProvider didUpdateData:(NSArray *)data;

@end

@interface QMSearchDataProvider : NSObject

@property (weak, nonatomic) QMSearchDataSource *dataSource;

@property (weak, nonatomic) id<QMSearchDataProviderDelegate> delegate;

- (void)performSearch:(NSString *)searchText;

@end
