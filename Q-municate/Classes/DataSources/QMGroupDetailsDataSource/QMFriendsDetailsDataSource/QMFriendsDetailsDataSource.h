//
//  QMFriendsDetailsDataSource.h
//  Qmunicate
//
//  Created by Igor Alefirenko on 15/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
   Friends details data source contains of array of cell identifiers;
 */

@interface QMFriendsDetailsDataSource : NSObject

@property (nonatomic, strong, readonly) NSArray *actionList;


- (id)initWithUser:(QBUUser *)user;

- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)cellIdentifiersCount;

@end
