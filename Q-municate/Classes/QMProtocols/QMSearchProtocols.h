//
//  QMSearchProtocols.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/2/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

@class QMTableViewSearchDataSource;
@class QBUUser;

@protocol QMSearchProtocol <NSObject>

@optional
- (QMTableViewSearchDataSource *)searchDataSource;

@end

@protocol QMDialogsSearchDataSourceProtocol <QMSearchProtocol>

@end

@protocol QMGlobalSearchDataSourceProtocol <QMSearchProtocol>

@end

@protocol QMContactsSearchDataSourceProtocol <QMSearchProtocol>

@optional
/**
 *  User at index path.
 *
 *  @param indexPath index path
 *
 *  @return user that is existent at a specific index path
 */
- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath;

@end
