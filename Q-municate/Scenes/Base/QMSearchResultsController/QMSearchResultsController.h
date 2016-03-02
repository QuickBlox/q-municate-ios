//
//  QMSearchResultsController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 2/29/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMSearchProtocols.h"

@interface QMSearchResultsController : UITableViewController <QMSearchProtocol>

- (void)performSearch:(NSString *)searchText;

@end
