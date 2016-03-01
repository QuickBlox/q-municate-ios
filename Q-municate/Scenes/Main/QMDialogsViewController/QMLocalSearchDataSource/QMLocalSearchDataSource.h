//
//  QMLocalSearchDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 2/29/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMTableViewDataSource.h"

@interface QMLocalSearchDataSource : QMTableViewDataSource

@property (strong, nonatomic) NSArray *contacts;
@property (strong, nonatomic) NSArray *dialogs;

@end
