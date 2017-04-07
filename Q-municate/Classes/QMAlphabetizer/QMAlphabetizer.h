//
//  QMAlphabetizer.h
//  Q-municate
//
//  Created by Andrey Ivanov on 23.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const CGLAlphabetizerGroupSortNameKey;
FOUNDATION_EXPORT NSString *const CGLAlphabetizerGroupObjectsKey;
FOUNDATION_EXPORT NSString *const CGLAlphabetizerGroupDisplayNameKey;

@interface QMAlphabetizer : NSObject

//MARK: - Alphabetization

/**
 *  Accepts an arbitrary array of objects and a key path to alphabetize by,
 *  and returns an NSDictionary keyed by first letter, with arrays of objects tied to each.
 *
 *  @param objects an array of objects to alphabetize, each of which should respond to keyPath
 *  @param keyPath a key path to drive alphabetization. @note that each object should respond to valueForKeyPath: with an NSString.
 *
 *  @return an NSDictionary keyed by first letter, containting sorted arrays of objects
 */
+ (NSDictionary *)alphabetizedDictionaryFromObjects:(NSArray *)objects
                                       usingKeyPath:(NSString *)keyPath;

/**
 *  Identical to [CGLAlphabetizer alphabetizedDictionaryFromObjects:usingKeyPath:], except this
 *  method allows supplying a custom placeholder for strings that don't begin with letters. # by default.
 */
+ (NSDictionary *)alphabetizedDictionaryFromObjects:(NSArray *)objects
                                       usingKeyPath:(NSString *)keyPath
                           nonAlphabeticPlaceholder:(NSString *)placeholder;

//MARK: - Grouping

/**
 *  Filters an array of objects into groups based on the response to keyPath, and then sorts those groups
 *  into alphabetical sections, similar to the iOS Music app, keyed by the first letter of those groups.
 *
 *  @param objects     an array of objects
 *  @param keyPath     a key path by which to group the objects. For example, song.artist.
 *  @param placeholder the placeholder to be used when the results of keyPath do not begin with a letter, or return nil
 *
 *  @return a dictionary, keyed by first letter, each value of which is a grouped dictionary with format
 *  @{ @"name" : resultOfKeyPath, @"objects" : anArrayOfMatchingObjects }
 */
+ (NSDictionary *)groupedDictionaryFromObjects:(NSArray *)objects
                                  usingKeyPath:(NSString *)keyPath
                                        sortBy:(NSString *)sortableKeyPath
                      nonAlphabeticPlaceholder:(NSString *)placeholder;


/**
 *  Generates a sorted array of index titles from an alphabetized dictionary.
 *
 *  You might use these to respond to the tableView datasource method sectionIndexTitlesForTableView.
 *
 *  @param alphabetizedDictionary an alphabetized dictionary
 *
 *  @return an array of index titles
 */
+ (NSArray *)indexTitlesFromAlphabetizedDictionary:(NSDictionary *)alphabetizedDictionary;

@end
