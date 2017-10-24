//
//  QMTableViewDataSource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
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
