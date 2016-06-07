//
//  QMContactsSearchDataProvider.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/17/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchDataProvider.h"

@interface QMContactsSearchDataProvider : QMSearchDataProvider

@property (strong, nonatomic) NSArray *friends;

@end
