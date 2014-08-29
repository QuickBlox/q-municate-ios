//
//  QMTableDataSource.h
//  Q-municate
//
//  Created by Igor Alefirenko on 28/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, copy) NSArray *friends;
@property (nonatomic, copy) NSArray *otherUsers;

@end
