//
//  DGTBranchConfiguration.h
//  DigitsKit
//
//  Created by Rajul Arora on 11/1/16.
//  Copyright © 2016 Twitter Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGTBranchConfiguration : NSObject <NSCopying>

/**
 *  Title property specified by the BranchUniversalObject
 */
@property (nonatomic, strong) NSString *title;

/**
 *  Content Description property specified by the BranchUniversalObject
 */
@property (nonatomic, strong) NSString *contentDescription;

/**
 *  Feature property specified by the BrankLinkParameter
 */
@property (nonatomic, strong) NSString *feature;


/**
 *  Creates an instance of DGTBranchConfiguration. This will return nil
 *  if the feature parameter is not set.
 */
- (instancetype)initWithFeature:(NSString *)feature;

@end
