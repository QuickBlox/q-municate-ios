//
//  QMAlphabetizedDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchDataSource.h"

/**
 *  This class represent alphabetized data source using a specific key path of objects, set to items.
 *  It is also can be used as a search data source.
 */
@interface QMAlphabetizedDataSource : QMSearchDataSource

/**
 *  Determines whether data source is empty or not.
 */
@property (assign, nonatomic, readonly) BOOL isEmpty;

#pragma mark - Unavailable constructors

- (instancetype _Nullable)init NS_UNAVAILABLE;
- (instancetype _Nullable)initWithSearchDataProvider:(QMSearchDataProvider * _Nonnull)searchDataProvider NS_UNAVAILABLE;

#pragma mark - Class construction

/**
 *  Init QMAlphabetizedDataSource with a key path.
 *
 *  @param keyPath keypath that will be used to alphabetize data source
 *
 *  @return QMAlphabetizedDataSource instance
 */
- (instancetype _Nullable)initWithKeyPath:(NSString * _Nonnull) keyPath;

/**
 *  Init QMAlphabetizedDataSource using a search data provider and a specific key path.
 *
 *  @param searchDataProvider search data provider to perform search filter on data source
 *  @param keyPath            keypath that will be used to alphabetize data source
 *
 *  @see QMSearchDataProvider class implementation for more info.
 *
 *  @return QMAlphabetizedDataSource instance
 */
- (instancetype _Nullable)initWithSearchDataProvider:(QMSearchDataProvider * _Nonnull)searchDataProvider usingKeyPath:(NSString * _Nonnull)keyPath;

#pragma mark - Methods

/**
 *  Object at index path.
 *
 *  @param indexPath index path
 *
 *  @return specific object, that is existent at index path
 */
- (id _Nullable)objectAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

@end
