//
//  QMTableViewDataSource.h
//  Q-municate
//
//  Created by Injoit on 01.04.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMDataSource.h"
#import "QMSearchDataSource.h"

@protocol QMTableViewDataSourceProtocol <UITableViewDataSource>

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface QMTableViewDataSource : QMDataSource <QMTableViewDataSourceProtocol>

@end


@interface QMTableViewSearchDataSource : QMTableViewDataSource <QMSearchDataSourceProtocol>

@end
