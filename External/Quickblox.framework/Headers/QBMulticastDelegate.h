//
//  QBMulticastDelegate.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface QBMulticastDelegate : NSObject

/**
 *  Adds the given delegate implementation to the list of observers.
 *
 *  @param delegate delegate to add
 */
- (void)addDelegate:(id)delegate;

/**
 *  Removes the given delegate implementation from the list of observers.
 *
 *  @param delegate delegate to remove
 */
- (void)removeDelegate:(id)delegate;

/**
 *  Removes all delegates.
 */
- (void)removeAllDelegates;

/**
 *  Hashtable of all delegates.
 */
- (NSHashTable *)delegates;

@end

NS_ASSUME_NONNULL_END
