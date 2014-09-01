//
//  QMSearchDataSource.h
//  Q-municate
//
//  Created by Igor Alefirenko on 01/09/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTableDataSource.h"

@interface QMSearchDataSource : QMTableDataSource

@property (nonatomic, copy) NSString *searchString;

@end
