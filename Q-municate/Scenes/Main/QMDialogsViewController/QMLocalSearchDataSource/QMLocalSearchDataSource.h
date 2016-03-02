//
//  QMLocalSearchDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 2/29/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMSearchProtocols.h"
#import "QMSearchDataSource.h"

@interface QMLocalSearchDataSource : QMSearchDataSource <QMLocalSearchDataSourceProtocol>

@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) NSMutableArray *dialogs;

@end
