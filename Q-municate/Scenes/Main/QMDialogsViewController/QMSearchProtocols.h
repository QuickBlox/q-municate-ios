//
//  QMSearchProtocols.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/2/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

@class QMTableViewDataSource;
@protocol QMLocalSearchDataSourceProtocol;

@protocol QMSearchProtocol <NSObject>

- (QMTableViewDataSource <QMLocalSearchDataSourceProtocol> *)searchDataSource;

@end

@protocol QMLocalSearchDataSourceProtocol <NSObject>

@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) NSMutableArray *dialogs;

@end
