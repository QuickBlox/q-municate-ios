//
//  QMAlphabetizedDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchDataSource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represent alphabetized data source using a specific key path of objects, set to items.
 *  It is also can be used as a search data source.
 */
@interface QMAlphabetizedDataSource : QMSearchDataSource

/**
 *  Determines whether data source is empty or not.
 */
@property (assign, nonatomic, readonly) BOOL isEmpty;

//MARK: - Unavailable constructors

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithSearchDataProvider:(QMSearchDataProvider *)searchDataProvider NS_UNAVAILABLE;

//MARK: - Class construction

/**
 *  Init QMAlphabetizedDataSource with a key path.
 *
 *  @param keyPath keypath that will be used to alphabetize data source
 *
 *  @return QMAlphabetizedDataSource instance
 */
- (nullable instancetype)initWithKeyPath:(NSString *) keyPath;

/**
 *  Init QMAlphabetizedDataSource using a search data provider and a specific key path.
 *
 *  @param searchDataProvider search data provider to perform search filter on data source
 *  @param keyPath            keypath that will be used to alphabetize data source
 *
 *  @see QMSearchDataProvider class implementation for more information.
 *
 *  @return QMAlphabetizedDataSource instance
 */
- (nullable instancetype)initWithSearchDataProvider:(QMSearchDataProvider *)searchDataProvider usingKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
