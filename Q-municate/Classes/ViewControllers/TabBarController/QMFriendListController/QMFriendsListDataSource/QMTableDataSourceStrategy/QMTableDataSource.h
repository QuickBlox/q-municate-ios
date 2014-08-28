//
//  QMTableDataSource.h
//  Q-municate
//
//  Created by Igor Alefirenko on 28/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong, readonly) NSArray *friends;
@property (nonatomic, strong, readonly) NSArray *otherUsers;

- (instancetype)initWithFriendsArray:(NSArray *)friendsArray otherUsersArray:(NSArray *)otherUsersArray;

@end
