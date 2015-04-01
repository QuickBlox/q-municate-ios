//
//  QMPagedTableViewDatasource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTableViewDatasource.h"

@interface QMPagedTableViewDatasource : QMTableViewDatasource

- (QBGeneralResponsePage *)responsePage;
- (void)updateCurrentPageWithResponcePage:(QBGeneralResponsePage *)page;

@end
