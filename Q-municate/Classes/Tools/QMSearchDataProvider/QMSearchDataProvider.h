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

NS_ASSUME_NONNULL_BEGIN

@class QMSearchDataProvider;

/**
 *  QMSearchDataProviderDelegate protocol. Used to notify about any tag view changes.
 */
@protocol QMSearchDataProviderDelegate <NSObject>

/**
 *  Protocol methods down below are required to be implemented
 */
@required

/**
 *  Notifying about search data provider did finish fetching data.
 *
 *  @param searchDataProvider QMSearchDataProvider instance
 */
- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)searchDataProvider;

/**
 *  Notifying about search data provider had updated data.
 *
 *  @param searchDataProvider QMSearchDataProvider instance
 *  @param data               array of updated data
 */
- (void)searchDataProvider:(QMSearchDataProvider *)searchDataProvider didUpdateData:(NSArray *)data;

@end

@interface QMSearchDataProvider : NSObject

@property (weak, nonatomic, nullable) QMSearchDataSource *dataSource;

@property (weak, nonatomic, nullable) id<QMSearchDataProviderDelegate> delegate;

- (void)performSearch:(NSString *)searchText;

@end

NS_ASSUME_NONNULL_END
